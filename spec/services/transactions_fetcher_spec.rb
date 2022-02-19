require 'rails_helper'

RSpec.describe TransactionsFetcher do
  before('all') do
    @account = create(:account, created_at: 1.year.ago)
    @user = create(:user, account: @account)
    @category = create(:category, plaid_category_id: Category::CC_PAYMENT_PLAID_ID)
    build_historical_transactions
  end

  describe 'with no params' do
    it 'queries transactions for all time' do
      fetcher = TransactionsFetcher.call(@account, Stat::ALL)
      expect(fetcher.aggregated_transactions.count).to eq(7)
      expect(fetcher.aggregated_transactions.total_spend).to eq(1200)
      expect(fetcher.start_date).to eq(@account.first_transaction_occured_at)
    end

    it 'queries transactions for the past week' do
      fetcher = TransactionsFetcher.call(@account, Stat::WEEKLY)
      expect(fetcher.aggregated_transactions.count).to eq(3)
      expect(fetcher.aggregated_transactions.total_spend).to eq(100)
      expect(fetcher.start_date).to eq(Date.today - 1.week)
    end

    it 'queries transactions for the past month' do
      fetcher = TransactionsFetcher.call(@account, Stat::MONTHLY)
      expect(fetcher.aggregated_transactions.count).to eq(4)
      expect(fetcher.aggregated_transactions.total_spend).to eq(200)
      expect(fetcher.start_date).to eq(Date.today - 1.month)
    end

    it 'queries transactions for the past 3 months' do
      fetcher = TransactionsFetcher.call(@account, Stat::QUARTERLY)
      expect(fetcher.aggregated_transactions.count).to eq(5)
      expect(fetcher.aggregated_transactions.total_spend).to eq(300)
      expect(fetcher.start_date).to eq(Date.today - 3.months)
    end

    it 'queries transactions for the past year' do
      fetcher = TransactionsFetcher.call(@account, Stat::YEARLY)
      expect(fetcher.aggregated_transactions.count).to eq(7)
      expect(fetcher.aggregated_transactions.total_spend).to eq(1200)
      expect(fetcher.start_date).to eq(Date.today - 1.year)
    end
  end

  describe 'with search query string' do
    let(:params) {
      {
        search_query: 'Amazon',
      }
    }
    it 'queries transactions for all time' do
      fetcher = TransactionsFetcher.call(@account, Stat::ALL, params)
      expect(fetcher.aggregated_transactions.count).to eq(5)
      expect(fetcher.aggregated_transactions.total_spend).to eq(1000)
    end

    it 'queries transactions for the past week' do
      fetcher = TransactionsFetcher.call(@account, Stat::WEEKLY, params)
      expect(fetcher.aggregated_transactions.count).to eq(1)
      expect(fetcher.aggregated_transactions.total_spend).to eq(-100)
    end

    it 'queries transactions for the past month' do
      fetcher = TransactionsFetcher.call(@account, Stat::MONTHLY, params)
      expect(fetcher.aggregated_transactions.count).to eq(2)
      expect(fetcher.aggregated_transactions.total_spend).to eq(0)
    end

    it 'queries transactions for the past 3 months' do
      fetcher = TransactionsFetcher.call(@account, Stat::QUARTERLY, params)
      expect(fetcher.aggregated_transactions.count).to eq(3)
      expect(fetcher.aggregated_transactions.total_spend).to eq(100)
    end

    it 'queries transactions for the past year' do
      fetcher = TransactionsFetcher.call(@account, Stat::YEARLY, params)
      expect(fetcher.aggregated_transactions.count).to eq(5)
      expect(fetcher.aggregated_transactions.total_spend).to eq(1000)
    end
  end

  private

  def build_historical_transactions
    create(:transaction, occured_at: Date.today, amount: -100, user: @user,
      description: 'Amazon.com')
    create(:transaction, occured_at: Date.today, amount: 100, user: @user, category: @category,
      description: 'Doordash')
    create(:transaction, occured_at: Date.today, amount: 100, user: @user, essential: false,
      description: 'Starbucks')
    create(:transaction, occured_at: 1.month.ago, amount: 100, user: @user, description: 'Amazon Tips*2HTSK0EL3')
    create(:transaction, occured_at: 3.month.ago, amount: 100, user: @user, description: 'Amazon Tips*2HTSK0EL3')
    create(:transaction, occured_at: 4.month.ago, amount: 400, user: @user, description: 'Amazon Tips*2HTSK0EL3')
    create(:transaction, occured_at: 1.year.ago, amount: 500, user: @user, description: 'Amazon Tips*2HTSK0EL3')
  end
end
