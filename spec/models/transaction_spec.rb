require 'rails_helper'

RSpec.describe Transaction, type: :model do
  before(:all) do 
    @user = create(:user)
    @bank_account = create(:bank_account, user: @user)
    @category = create(:category)
  end
  
  it 'has 0 recurring transaction' do
    create(:transaction, description: 'tx1', user: @user, bank_account: @bank_account, category: @category)
    create(:transaction, description: 'tx2', user: @user, bank_account: @bank_account, category: @category)
    expect(@user.transactions.count).to eq 2
    hash = @user.process_recurring_transactions
    expect(@user.subscriptions.count).to eq 0
  end
  
  it 'has 5 recurring transaction' do
    pending 'pending subscription fix'
    create_recurring_transactions('monthly-sub', 'monthly')
    create_recurring_transactions('yearly-sub', 'yearly')
    create_recurring_transactions('daily-sub', 'daily')
    create_recurring_transactions('weekly-sub', 'weekly')
    create_recurring_transactions('quarterly-sub', 'quarterly')
    expect(@user.transactions.count).to eq 25
    hash = @user.process_recurring_transactions
    expect(@user.subscriptions.count).to eq 5
  end
  
  describe "#create_transactions_from_json" do
    let(:transaction_id) { SecureRandom.hex(32) }
    let(:transaction) {
      {
        account_id: @bank_account.plaid_account_id,
        amount: 123.52, 
        category_id: @category.plaid_category_id,
        date: Date.today.iso8601,
        iso_currency_code: "USD",
        name: "Amazon.com",
        payment_channel:"online",
        payment_meta: nil,
        pending: false,
        transaction_id: transaction_id,
        transaction_type: "place"
      }
    }

    it 'creates transactions' do
      expect(Transaction.create_transactions_from_json([transaction], @user.id).count).to eq 1
    end

    it 'raises an exception for duplicate records' do
      Transaction.create_transactions_from_json([transaction], @user.id)
      expect(Transaction.find_by_plaid_transaction_id(transaction_id).occured_at).to eq Date.today
      new_date = Date.today + 1.day
      amount = 50
      updated_tx = transaction.merge(date: new_date.iso8601, amount: amount)
      Transaction.create_transactions_from_json([updated_tx], @user.id)
      updated_tx = Transaction.find_by_plaid_transaction_id(transaction_id)
      expect(updated_tx.occured_at).to eq new_date
    end
  end
  
  after(:all) do 
    Category.destroy_all
    BankAccount.destroy_all
    Transaction.destroy_all
    User.destroy_all
  end

  private

  def create_recurring_transactions(description, frequency)
    freq = case frequency
      when 'daily' then 1.day
      when 'weekly' then 1.week
      when 'monthly' then 1.month
      when 'quarterly' then 3.month
      when 'yearly' then 1.year
    end
    (1..5).each do |n|
      create(
        :transaction,
        description: description,
        occured_at: (n*freq).ago,
        user: @user,
        bank_account: @bank_account,
        category: @category
      )
    end
  end
  
  def transaction_json(account_id, category_id, transaction_id)
    {
      account_id: account_id,
      amount: 123.52, 
      category_id: category_id,
      date: Date.today.iso8601,
      iso_currency_code: "USD",
      name: "Amazon.com",
      payment_channel:"online",
      payment_meta: nil,
      pending: false,
      transaction_id: transaction_id,
      transaction_type: "place"
    }
  end
end
