class CreateAccountTypes < ActiveRecord::Migration[6.0]
  def change
    create_table :account_types do |t|
      t.string :name
      t.string :description
      t.boolean :asset_category
      t.jsonb :subtype_array

      t.timestamps
    end

    AccountType.create(
      name: 'depository', description: 'Bank', asset_category: true, subtype_array: [
        {'name': 'checking', 'description': 'Checking'},
        {'name': 'savings', 'description': 'Savings'},
        {'name': 'hsa', 'description': 'Health Savings Account (HSA)'},
        {'name': 'cd', 'description': 'Certificate of Deposit (CD)'},
        {'name': 'money market', 'description': 'Money Market'},
        {'name': 'other', 'description': 'Other'},
      ]
    )
    AccountType.create(
      name: 'credit', description: 'Credit Card', asset_category: false, subtype_array: [
        {'name': 'credit card', 'description': 'Credit Card'},
      ]
    )
    AccountType.create(
      name: 'cash', description: 'Cash', asset_category: true, subtype_array: [
        {'name': 'cash', 'description': 'Cash'},
      ]
    )
    AccountType.create(
      name: 'collectible', description: 'Collectibles', asset_category: true, subtype_array: [
        {'name': 'art', 'description': 'Art'},
        {'name': 'wine', 'description': 'Wine'},
        {'name': 'jewelery', 'description': 'Jewelery'},
        {'name': 'other', 'description': 'Other'},
      ]
    )
    AccountType.create(
      name: 'loan', description: 'Loan', asset_category: false, subtype_array: [
        {'name': 'auto', 'description': 'Auto'},
        {'name': 'business', 'description': 'Business'},
        {'name': 'commercial', 'description': 'Commerical Mortgage'},
        {'name': 'mortgage', 'description': 'Home Mortgage'},
        {'name': 'line of credit', 'description': 'Line of Credit'},
        {'name': 'student', 'description': 'Student'},
        {'name': 'other', 'description': 'Other'},
      ]
    )
    AccountType.create(
      name: 'investment', description: 'Investment', asset_category: true, subtype_array: [
        {'name': '529', 'description': '529 College Savings Plan'},
        {'name': '401a', 'description': '401(a) Retirement'},
        {'name': '401k', 'description': '401(k) Retirement'},
        {'name': '403b', 'description': '403(b) Retirement'},
        {'name': '457b', 'description': '457(b) Retirement'},
        {'name': 'brokerage', 'description': 'Brokerage'},
        {'name': 'hsa', 'description': 'Medical Health Savings Account (HSA) '},
        {'name': 'ira', 'description': 'Traditional IRA (pre-tax)'},
        {'name': 'mutual fund', 'description': 'Mutual Fund'},
        {'name': 'pension', 'description': 'Pension'},
        {'name': 'roth', 'description': 'Roth IRA (after-tax)'},
        {'name': 'roth 401k', 'description': 'Roth 401(k)'},
        {'name': 'simple ira', 'description': 'SIMPLE IRA'},
        {'name': 'stock options', 'description': 'Stock Options'},
        {'name': 'rsu', 'description': 'RSUs'},
        {'name': 'trust', 'description': 'Trust'},
        {'name': 'other', 'description': 'Other'},
      ]
    )
    AccountType.create(
      name: 'real estate', description: 'Real Estate', asset_category: true, subtype_array: [
        {'name': 'primary residence', 'description': 'Primary Residence'},
        {'name': 'secondary residence', 'description': 'Secondary Residence'},
        {'name': 'commerical', 'description': 'Commerical'},
        {'name': 'other', 'description': 'Other'},
      ]
    )
    AccountType.create(
      name: 'other asset', description: 'Other Asset', asset_category: true, subtype_array: [
        {'name': 'other', 'description': 'Other'},
      ]
    )
    AccountType.create(
      name: 'other liability', description: 'Other Liability', asset_category: false, subtype_array: [
        {'name': 'other', 'description': 'Other'},
      ]
    )
  end
end
