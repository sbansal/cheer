class Transaction < ApplicationRecord
  include Categorizeable

  belongs_to :bank_account
  belongs_to :user
  belongs_to :category
  belongs_to :duplicate_transaction, class_name: 'Transaction', foreign_key: 'duplicate_transaction_id', optional: true

  validates :custom_description, :category_id, presence: true

  # callbacks
  after_update_commit { broadcast_replace_to "transactions", partial: 'transactions/transaction_summary', locals: {transaction: self} }
  after_destroy_commit do
    broadcast_remove_to("transactions")
  end

  scope :occured_between, ->(start_date, end_date) { where(occured_at: start_date..end_date)}
  scope :with_category, ->(category_name) { joins(:category).where("hierarchy @> ?", '' + "#{category_name}" + '') }
  scope :with_category_description, ->(root_name) { joins(:category).where("descriptive_name = ?", root_name) }
  scope :debits, -> {joins(:category).where('amount >= 0 and plaid_category_id not in (?)', Category::IGNORE_LIST)}
  scope :credits, -> {joins(:category).where('amount < 0 and plaid_category_id not in (?)',
    Category::IGNORE_LIST.concat(Category::CREDIT_IGNORE_LIST).uniq)}
  scope :investments, -> {joins(:category).where('plaid_category_id in (?)', Category::INVESTMENT_CATEGORIES_LIST)}
  

  def self.create_transactions_from_json(transactions_json_array, user_id)
    transactions = process_transactions_json(transactions_json_array, user_id)
    Rails.logger.info("Total transactions to be saved in the DB = #{transactions.compact.count}")
    if transactions.compact.empty?
      Rails.logger.info("No transactions saved to the DB.")
      []
    else
      begin
        result = Transaction.upsert_all(transactions.compact, unique_by: [:plaid_transaction_id])
        Rails.logger.info("Total transactions actually saved to DB=#{result.length}")
        result
      rescue => e
        Rails.logger.error("Upsert failed for #{transactions.length} transactions. Exception=#{e}")
      end
    end
  end

  def status
    pending? ? 'pending' : 'settled'
  end

  def debit?
    amount >= 0 && !category.ignore_for_debit?
  end

  def credit?
    amount < 0 && !category.ignore_for_credit?
  end

  def formatted_occurred_at
    if Date.today.year == occured_at.year
      occured_at.strftime('%b %-d')
    else
      occured_at.strftime('%b %-d, %Y')
    end
  end

  def related_transactions
    if self.merchant_name
      Transaction.fuzzy_search(description: self.description)
        .where(user: self.user, category: self.category, merchant_name: self.merchant_name)
        .where.not(id: id)
        .order('occured_at desc')
    else
      Transaction.fuzzy_search(description: self.description)
        .where(user: self.user, category: self.category)
        .where.not(id: id)
        .order('occured_at desc')
    end
  end

  def update_related(transactions_params, related_ids)
    if transactions_params[:custom_description]
      Transaction.where(id: related_ids, user_id: self.user_id)
        .update(custom_description: transactions_params[:custom_description], updated_at: Time.zone.now.utc)
    elsif transactions_params[:category_id]
      Transaction.where(id: related_ids, user_id: self.user_id)
        .update(category_id: transactions_params[:category_id], updated_at: Time.zone.now.utc)
    elsif transactions_params[:essential]
      Transaction.where(id: related_ids, user_id: self.user_id)
        .update(essential: transactions_params[:essential], updated_at: Time.zone.now.utc)
    end
  end

  def find_duplicates
    return [] unless plaid_pending_transaction_id
    duplicate_txs = Transaction.where(plaid_transaction_id: plaid_pending_transaction_id).where.not(id: id)
    if duplicate_txs.empty?
      duplicate_txs = Transaction.where(
        description: description,
        occured_at: occured_at,
        amount: amount,
      ).where.not(id: id)
    end
    duplicate_txs.map(&:id)
  end

  def tag_duplicates
    if self.duplicate_resolved_at.nil?
      duplicate_txs = find_duplicates
      unless duplicate_txs.empty?
        if duplicate_txs.count > 1
          Rails.logger.error("Multiple duplicate transactions for transaction id #{id} found. Duplicates - #{duplicate_txs}")
        else
          Rails.logger.info("Marking transaction as duplicate with id=#{duplicate_txs.first}")
          update(duplicate: true, duplicate_transaction_id: duplicate_txs.first)
        end
      end
    end
  end

  def refund?
    amount < 0 && !category.payroll?
  end

  def payroll?
    amount < 0 && category.payroll?
  end

  def fee_charged?
    amount > 0 && category.bank_fee_charged?
  end

  def summary_json
    {
      amount: amount,
      custom_description: custom_description,
      merchant_name: merchant_name,
      occured_at: occured_at,
      category: category.category_list,
      essential: essential,
      bank_account: bank_account.summary_json,
    }
  end
  
  def cleanup_after_destroy
    resolve_duplicate
    unless self.user.nil?
      StatsCreatorJob.perform_later(self.user.company_id)
    end
  end

  private

  def resolve_duplicate
    duplicate = Transaction.find_by(duplicate_transaction_id: id)
    if duplicate
      duplicate.update(duplicate: false, duplicate_transaction_id: nil, duplicate_resolved_at: Time.zone.now)
    else
      true
    end
  end

  def self.process_transactions_json(transactions_json_array, user_id)
    transactions_json_array.map do |transactions_json|
      begin
        bank_account = BankAccount.find_by!(plaid_account_id: transactions_json.account_id)
        category = Category.find_by!(plaid_category_id: transactions_json.category_id)
        transaction = Transaction.find_by_plaid_transaction_id(transactions_json.transaction_id)
        created_at = transaction.nil? ? Time.zone.now.utc : transaction.created_at
        custom_description = transaction.nil? ? transactions_json.name : transaction.custom_description
        category_id = transaction.nil? ? category&.id : transaction.category_id
        essential_tx = transaction.nil? ? category.essential? : transaction.category.essential?
        {
          plaid_transaction_id: transactions_json.transaction_id,
          user_id: user_id,
          amount: transactions_json.amount,
          currency_code: transactions_json.iso_currency_code,
          occured_at: transactions_json.date,
          authorized_at: transactions_json.authorized_date,
          location_json: transactions_json.location,
          description: transactions_json.name,
          custom_description: custom_description,
          transaction_type: transactions_json.transaction_type,
          payment_meta_json: transactions_json.payment_meta,
          payment_channel: transactions_json.payment_channel,
          pending: transactions_json.pending,
          plaid_pending_transaction_id: transactions_json.pending_transaction_id,
          transaction_code: transactions_json.transaction_code,
          bank_account_id: bank_account&.id,
          category_id: category_id,
          created_at: created_at,
          updated_at: Time.zone.now.utc,
          merchant_name:transactions_json.merchant_name,
          essential: essential_tx,
        }
      rescue => e
        Rails.logger.error("Unable to process transaction with payload: #{transactions_json}, exception - #{e}")
        Rails.logger.error(e.backtrace.join("\n"))
        TransactionError.create(
          user_id: user_id,
          transaction_json: transactions_json,
          error_message: e.full_message,
          error_type: e.class.name,
        )
        next
      end
    end
  end
end
