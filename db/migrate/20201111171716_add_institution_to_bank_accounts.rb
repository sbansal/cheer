class AddInstitutionToBankAccounts < ActiveRecord::Migration[6.0]
  def up
    add_column :bank_accounts, :institution_id, :integer
    BankAccount.all.each do |account|
      account.update(institution_id: account.login_item.institution_id)
    end
  end

  def down
    remove_column :bank_accounts, :institution_id
  end
end
