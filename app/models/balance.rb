class Balance < ApplicationRecord
  belongs_to :user
  belongs_to :bank_account

  def self.create_balances_from_accounts_json(accounts_json)
    balances = accounts_json.map do |account_json|
      begin
        bank_account = BankAccount.find_by!(plaid_account_id: account_json[:account_id])
        {
          available: account_json.balances.available,
          current: account_json.balances.current,
          limit: account_json.balances.limit,
          currency_code: account_json.balances.iso_currency_code || account_json.balances.unofficial_currency_code,
          bank_account_id: bank_account.id,
          user_id: bank_account.user_id,
        }
      rescue => e
        Rails.logger.error("Unable to create balance with payload: #{account_json}, exception - #{e}")
        Rails.logger.error(e.backtrace.join("\n"))
        next
      end
    end
    create(balances)
  end
end
