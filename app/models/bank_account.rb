class BankAccount < ApplicationRecord
  has_many :transactions, dependent: :destroy
  belongs_to :user
  belongs_to :login_item
  
  def self.create_accounts_from_json(accounts_json_array, login_item_id, user_id)
    banks_accounts = accounts_json_array.map do |account_json|
      {
        plaid_account_id: account_json.account_id,
        name: account_json.name,
        official_name: account_json.official_name,
        account_type: account_json.type,
        account_subtype: account_json.subtype,
        mask: account_json.mask,
        balance_available: account_json.balances.available,
        balance_limit: account_json.balances.limit,
        balance_currency_code: account_json.balances.iso_currency_code || account_json.balances.unofficial_currency_code, 
        login_item_id: login_item_id,
        user_id: user_id,
      }
    end
    create!(banks_accounts)
  end
end
