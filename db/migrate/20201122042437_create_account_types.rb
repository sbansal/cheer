class CreateAccountTypes < ActiveRecord::Migration[6.0]
  def change
    create_table :account_types do |t|
      t.string :name
      t.jsonb :subtype_array

      t.timestamps
    end

    AccountType.create(
      name: 'depository', subtype_array: [
        {'name': 'checking', 'description': 'Checking account'},
        {'name': 'savings', 'description': 'Savings account'},
        {'name': 'hsa', 'description': 'Health Savings account'},
        {'name': 'cd', 'description': 'Certificate of deposit account'},
        {'name': 'money market', 'description': 'Money market account'},
        {'name': 'paypal', 'description': 'Paypal depository account'},
        {'name': 'prepaid', 'description': 'Prepaid debit card'},
        {'name': 'cash management', 'description': 'Cash management account'},
        {'name': 'ebt', 'description': 'Electronic Benefit Transfer account'},
      ]
    )
    AccountType.create(
      name: 'credit', subtype_array: [
        {'name': 'credit card', 'description': 'Bank issued credit card'},
        {'name': 'paypal', 'description': 'Paypal issued credit card'},
      ]
    )
    AccountType.create(
      name: 'loan', subtype_array: [
        {'name': 'auto', 'description': 'Auto loan'},
        {'name': 'commercial', 'description': 'Commercial loan'},
        {'name': 'construction', 'description': 'Construction loan'},
        {'name': 'consumer', 'description': 'Consumer loan'},
        {'name': 'home equity', 'description': 'Home Equity Line of Credit (HELOC)'},
        {'name': 'loan', 'description': 'General loan'},
        {'name': 'mortgage', 'description': 'Mortgage loan'},
        {'name': 'overdraft', 'description': 'Pre-approved overdraft account'},
        {'name': 'line of credit', 'description': 'Pre-approved line of credit'},
        {'name': 'student', 'description': 'Student loan'},
        {'name': 'other', 'description': 'Other loan type'},
      ]
    )
    AccountType.create(
      name: 'investment', subtype_array: [
        {'name': '529', 'description': 'Tax-advantaged college savings and prepaid tuition 529 plans'},
        {'name': '401a', 'description': 'Employer-sponsored money-purchase 401(a) retirement plan'},
        {'name': '401k', 'description': 'Standard 401(k) retirement account'},
        {'name': '403b', 'description': '403(b) retirement savings account for non-profits and schools'},
        {'name': '457b', 'description': 'Tax-advantaged deferred-compensation 457(b) retirement plan for governments and non-profits'},
        {'name': 'brokerage', 'description': 'Standard brokerage account'},
        {'name': 'cash isa', 'description': 'Individual Savings Account (ISA) that pays interest tax-free'},
        {'name': 'education savings account', 'description': 'Tax-advantaged Coverdell Education Savings Account (ESA)'},
        {'name': 'fixed annuity', 'description': 'Fixed annuity'},
        {'name': 'gic', 'description': 'Guaranteed Investment Certificate (Canada)'},
        {'name': 'health reimbursement arrangement', 'description': 'Tax-advantaged Health Reimbursement Arrangement (HRA) benefit plan'},
        {'name': 'hsa', 'description': 'Non-cash tax-advantaged medical Health Savings Account (HSA) '},
        {'name': 'ira', 'description': 'Traditional Invididual Retirement Account (IRA)'},
        {'name': 'isa', 'description': 'Non-cash Individual Savings Account (ISA)'},
        {'name': 'keogh', 'description': 'Keogh self-employed retirement plan'},
        {'name': 'lif', 'description': 'Life Income Fund (LIF) retirement account'},
        {'name': 'lira', 'description': 'Locked-in Retirement Account (LIRA)'},
        {'name': 'lrif', 'description': 'Locked-in Retirement Income Fund (LRIF)'},
        {'name': 'lrsp', 'description': 'Locked-in Retirement Savings Plan'},
        {'name': 'mutual fund', 'description': 'Mutual fund account'},
        {'name': 'non-taxable brokerage account', 'description': 'Non-taxable brokerage account'},
        {'name': 'pension', 'description': 'Standard pension account'},
        {'name': 'prif', 'description': 'Prescribed Registered Retirement Income Fund'},
        {'name': 'profit sharing plan', 'description': 'Plan that gives employees share of company profits'},
        {'name': 'qshr', 'description': 'Qualifying share account'},
        {'name': 'rdsp', 'description': 'Registered Disability Savings Plan (RSDP)'},
        {'name': 'resp', 'description': 'Registered Education Savings Plan'},
        {'name': 'retirement', 'description': 'Retirement account'},
        {'name': 'rlif', 'description': 'Restricted Life Income Fund (RLIF)'},
        {'name': 'roth', 'description': 'Roth IRA'},
        {'name': 'roth 401k', 'description': 'Employer-sponsored Roth 401(k) plan'},
        {'name': 'rrif', 'description': 'Registered Retirement Income Fund (RRIF) '},
        {'name': 'rrsp', 'description': 'Registered Retirement Savings Plan'},
        {'name': 'sarsep', 'description': 'Salary Reduction Simplified Employee Pension Plan'},
        {'name': 'sep ira', 'description': 'Simplified Employee Pension IRA (SEP IRA)'},
        {'name': 'simple ira', 'description': 'Savings Incentive Match Plan for Employees IRA'},
        {'name': 'sipp', 'description': 'Self-Invested Personal Pension (SIPP)'},
        {'name': 'stock plan', 'description': 'Standard stock plan account'},
        {'name': 'tfsa', 'description': 'Tax-Free Savings Account (TFSA)'},
        {'name': 'trust', 'description': 'Trust Account'},
        {'name': 'ugma', 'description': 'Uniform Gift to Minors Act'},
        {'name': 'utma', 'description': 'Uniform Transfers to Minors Act'},
        {'name': 'variable annuity', 'description': 'Tax-deferred capital accumulation annuity contract'},
      ]
    )
    AccountType.create(
      name: 'other', subtype_array: []
    )
  end
end
