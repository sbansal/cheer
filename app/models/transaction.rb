class Transaction < ApplicationRecord
  belongs_to :bank_account
  belongs_to :user
  
  scope :occured_between, ->(start_date, end_date) { where(occured_at: start_date..end_date)}
  
  INTERNAL_ACCOUNT_TRANSFER = 'Internal Account Transfer'

  def self.create_transactions_from_json(transactions_json_array, user_id)
    transactions = transactions_json_array.map do |transactions_json|
      bank_account = BankAccount.find_by_plaid_account_id(transactions_json.account_id)
      {
        plaid_transaction_id: transactions_json.transaction_id,
        amount: transactions_json.amount,
        currency_code: transactions_json.iso_currency_code,
        category_json: transactions_json.category,
        plaid_category_id: transactions_json.category_id,
        occured_at: Date.parse(transactions_json.date),
        authorized_at: transactions_json.authorized_date,
        location_json: transactions_json.location,
        description: transactions_json.name,
        transaction_type: transactions_json.transaction_type,
        payment_meta_json: transactions_json.payment_meta,
        payment_channel: transactions_json.payment_channel,
        pending: transactions_json.pending,
        plaid_pending_transaction_id: transactions_json.transaction_id,
        transaction_code: transactions_json.transaction_code,
        user_id: user_id,
        bank_account_id: bank_account&.id
      }
    end
    create!(transactions)
  end

  def category_list
    category_json.join(', ')
  end
  
  def payment?
    amount > 0 && (transaction_type == 'digital' || transaction_type == 'place')
  end
  
  def internal_account_transfer?
    category_json.include?(INTERNAL_ACCOUNT_TRANSFER)
  end
end
