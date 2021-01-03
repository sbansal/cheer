class AddCurrentBalanceToBankAccounts < ActiveRecord::Migration[6.1]
  def change
    add_column :bank_accounts, :current_balance, :float
    add_column :bank_accounts, :current_balance_updated_at, :datetime

    BankAccount.all.each do |account|
      account.update(current_balance: account.last_balance&.current, current_balance_updated_at: Time.zone.now)
    end
  end
end
