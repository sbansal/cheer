class Transaction < ApplicationRecord
  belongs_to :bank_account
  belongs_to :user
  belongs_to :category

  scope :occured_between, ->(start_date, end_date) { where(occured_at: start_date..end_date)}
  scope :with_category, ->(category_name) { joins(:category).where("hierarchy @> ?", '' + "#{category_name}" + '') }
  scope :with_category_description, ->(root_name) { joins(:category).where("descriptive_name = ?", root_name) }
  scope :essential, -> { joins(:category).where("essential = TRUE") }
  scope :non_essential, -> { joins(:category).where("essential = FALSE") }

  def self.create_transactions_from_json(transactions_json_array, user_id)
    transactions = process_transactions_json(transactions_json_array, user_id)
    Rails.logger.info("Total transactions to be saved in the DB = #{transactions.compact.count}")
    if transactions.compact.empty?
      Rails.logger.info("No transactions saved to the DB.")
    else
      begin
        result = Transaction.upsert_all(transactions.compact, unique_by: [:plaid_transaction_id])
        Rails.logger.info("Total transactions actually saved to DB=#{result.length}")
        result
      rescue => e
        Rails.logger.error("Upsert failed for #{result.length} transactions. Exception=#{e}")
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
    Transaction.where(merchant_name: self.merchant_name, user_id: self.user_id).fuzzy_search(description: self.description)
  end

  private

  def self.process_transactions_json(transactions_json_array, user_id)
    transactions_json_array.map do |transactions_json|
      begin
        bank_account = BankAccount.find_by!(plaid_account_id: transactions_json[:account_id])
        category = Category.find_by!(plaid_category_id: transactions_json[:category_id])
        transaction = Transaction.find_by_plaid_transaction_id(transactions_json[:transaction_id])
        created_at = transaction.nil? ? Time.zone.now.utc : transaction.created_at
        {
          plaid_transaction_id: transactions_json[:transaction_id],
          user_id: user_id,
          amount: transactions_json[:amount],
          currency_code: transactions_json[:iso_currency_code],
          occured_at: Date.parse(transactions_json[:date]),
          authorized_at: transactions_json[:authorized_date],
          location_json: transactions_json[:location],
          description: transactions_json[:name],
          custom_description: transactions_json[:name],
          transaction_type: transactions_json[:transaction_type],
          payment_meta_json: transactions_json[:payment_meta],
          payment_channel: transactions_json[:payment_channel],
          pending: transactions_json[:pending],
          plaid_pending_transaction_id: transactions_json[:pending_transaction_id],
          transaction_code: transactions_json[:transaction_code],
          bank_account_id: bank_account&.id,
          category_id: category&.id,
          created_at: created_at,
          updated_at: Time.zone.now.utc,
          merchant_name:transactions_json[:merchant_name],
        }
      rescue => e
        Rails.logger.error("Unable to process transaction with payload: #{transactions_json}, exception - #{e}")
        next
      end
    end
  end
end
