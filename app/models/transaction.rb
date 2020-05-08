class Transaction < ApplicationRecord
  belongs_to :bank_account
  belongs_to :user
  belongs_to :category
  
  scope :occured_between, ->(start_date, end_date) { where(occured_at: start_date..end_date)}
  scope :with_category, ->(category_name) { joins(:category).where("hierarchy @> ?", '' + "#{category_name}" + '') }
  scope :with_category_decription, ->(root_name) { joins(:category).where("descriptive_name = ?", root_name) }
  scope :essential, -> { joins(:category).where("essential = TRUE") }
  scope :non_essential, -> { joins(:category).where("essential = FALSE") }

  def self.create_transactions_from_json(transactions_json_array, user_id)
    transactions = transactions_json_array.map do |transactions_json|
      bank_account = BankAccount.find_by_plaid_account_id(transactions_json[:account_id])
      category = Category.find_by_plaid_category_id(transactions_json[:category_id])
      transaction = Transaction.find_or_initialize_by({ plaid_transaction_id: transactions_json[:transaction_id], user_id: user_id })
      transaction.assign_attributes({
        amount: transactions_json[:amount],
        currency_code: transactions_json[:iso_currency_code],
        occured_at: Date.parse(transactions_json[:date]),
        authorized_at: transactions_json[:authorized_date],
        location_json: transactions_json[:location],
        description: transactions_json[:name],
        transaction_type: transactions_json[:transaction_type],
        payment_meta_json: transactions_json[:payment_meta],
        payment_channel: transactions_json[:payment_channel],
        pending: transactions_json[:pending],
        plaid_pending_transaction_id: transactions_json[:pending_transaction_id],
        transaction_code: transactions_json[:transaction_code],
        bank_account_id: bank_account&.id,
        category_id: category&.id
      })
      transaction.save!
    end
  end

  def charge?
    amount > 0 && !pending? && category.charge?
  end
end
