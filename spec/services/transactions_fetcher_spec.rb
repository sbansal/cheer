require 'rails_helper'

RSpec.describe TransactionsFetcher do
  before('all') do
    @company = create(:company, created_at: 1.year.ago)
    @user = create(:user, company: @company)
    @category = create(:category, plaid_category_id: Category::CC_PAYMENT_PLAID_ID)
    @category_1 = create(:category, plaid_category_id: Category::INVESTMENTS_FINANCIAL_PLANNING_PLAID_ID)
    @bank_account = create(:bank_account, user: @user)
    @bank_account_1 = create(:bank_account, user: @user)
    build_historical_transactions
  end

  describe 'with no params' do
    it 'queries transactions for all time' do
      fetcher = TransactionsFetcher.call(@company, Stat::ALL)
      expect(fetcher.aggregated_transactions.count).to eq(7)
      expect(fetcher.aggregated_transactions.total_spend).to eq(1200)
      expect(fetcher.start_date).to eq(@company.first_transaction_occured_at)
    end

    it 'queries transactions for the past week' do
      fetcher = TransactionsFetcher.call(@company, Stat::WEEKLY)
      expect(fetcher.aggregated_transactions.count).to eq(3)
      expect(fetcher.aggregated_transactions.total_spend).to eq(100)
      expect(fetcher.start_date).to eq(Date.today - 1.week)
    end

    it 'queries transactions for the past month' do
      fetcher = TransactionsFetcher.call(@company, Stat::MONTHLY)
      expect(fetcher.aggregated_transactions.count).to eq(4)
      expect(fetcher.aggregated_transactions.total_spend).to eq(200)
      expect(fetcher.start_date).to eq(Date.today - 1.month)
    end

    it 'queries transactions for the past 3 months' do
      fetcher = TransactionsFetcher.call(@company, Stat::QUARTERLY)
      expect(fetcher.aggregated_transactions.count).to eq(5)
      expect(fetcher.aggregated_transactions.total_spend).to eq(300)
      expect(fetcher.start_date).to eq(Date.today - 3.months)
    end

    it 'queries transactions for the past year' do
      fetcher = TransactionsFetcher.call(@company, Stat::YEARLY)
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
      fetcher = TransactionsFetcher.call(@company, Stat::ALL, params)
      expect(fetcher.aggregated_transactions.count).to eq(5)
      expect(fetcher.aggregated_transactions.total_spend).to eq(1000)
    end

    it 'queries transactions for the past week' do
      fetcher = TransactionsFetcher.call(@company, Stat::WEEKLY, params)
      expect(fetcher.aggregated_transactions.count).to eq(1)
      expect(fetcher.aggregated_transactions.total_spend).to eq(-100)
    end

    it 'queries transactions for the past month' do
      fetcher = TransactionsFetcher.call(@company, Stat::MONTHLY, params)
      expect(fetcher.aggregated_transactions.count).to eq(2)
      expect(fetcher.aggregated_transactions.total_spend).to eq(0)
    end

    it 'queries transactions for the past 3 months' do
      fetcher = TransactionsFetcher.call(@company, Stat::QUARTERLY, params)
      expect(fetcher.aggregated_transactions.count).to eq(3)
      expect(fetcher.aggregated_transactions.total_spend).to eq(100)
    end

    it 'queries transactions for the past year' do
      fetcher = TransactionsFetcher.call(@company, Stat::YEARLY, params)
      expect(fetcher.aggregated_transactions.count).to eq(5)
      expect(fetcher.aggregated_transactions.total_spend).to eq(1000)
    end
  end

  describe 'with bank account' do
    let(:params) {
      {
        bank_account_id: [@bank_account.id],
      }
    }
    let(:alternate_params) {
      {
        bank_account_id: [@bank_account.id, @bank_account_1.id],
      }
    }
    it 'queries transactions for all time' do
      fetcher = TransactionsFetcher.call(@company, Stat::ALL, params)
      expect(fetcher.aggregated_transactions.count).to eq(6)
      expect(fetcher.aggregated_transactions.total_spend).to eq(1300)
      fetcher = TransactionsFetcher.call(@company, Stat::ALL, alternate_params)
      expect(fetcher.aggregated_transactions.count).to eq(7)
      expect(fetcher.aggregated_transactions.total_spend).to eq(1200)
    end

    it 'queries transactions for the past week' do
      fetcher = TransactionsFetcher.call(@company, Stat::WEEKLY, params)
      expect(fetcher.aggregated_transactions.count).to eq(2)
      expect(fetcher.aggregated_transactions.total_spend).to eq(200)
      fetcher = TransactionsFetcher.call(@company, Stat::WEEKLY, alternate_params)
      expect(fetcher.aggregated_transactions.count).to eq(3)
      expect(fetcher.aggregated_transactions.total_spend).to eq(100)
    end

    it 'queries transactions for the past month' do
      fetcher = TransactionsFetcher.call(@company, Stat::MONTHLY, params)
      expect(fetcher.aggregated_transactions.count).to eq(3)
      expect(fetcher.aggregated_transactions.total_spend).to eq(300)
      fetcher = TransactionsFetcher.call(@company, Stat::MONTHLY, alternate_params)
      expect(fetcher.aggregated_transactions.count).to eq(4)
      expect(fetcher.aggregated_transactions.total_spend).to eq(200)
    end

    it 'queries transactions for the past 3 months' do
      fetcher = TransactionsFetcher.call(@company, Stat::QUARTERLY, params)
      expect(fetcher.aggregated_transactions.count).to eq(4)
      expect(fetcher.aggregated_transactions.total_spend).to eq(400)
      fetcher = TransactionsFetcher.call(@company, Stat::QUARTERLY, alternate_params)
      expect(fetcher.aggregated_transactions.count).to eq(5)
      expect(fetcher.aggregated_transactions.total_spend).to eq(300)
    end

    it 'queries transactions for the past year' do
      fetcher = TransactionsFetcher.call(@company, Stat::YEARLY, params)
      expect(fetcher.aggregated_transactions.count).to eq(6)
      expect(fetcher.aggregated_transactions.total_spend).to eq(1300)
      fetcher = TransactionsFetcher.call(@company, Stat::YEARLY, alternate_params)
      expect(fetcher.aggregated_transactions.count).to eq(7)
      expect(fetcher.aggregated_transactions.total_spend).to eq(1200)
    end
  end

  describe 'with category' do
    let(:params) {
      {
        categories: [@category.id, @category_1.id]
      }
    }
    it 'queries transactions for all time' do
      fetcher = TransactionsFetcher.call(@company, Stat::ALL, params)
      expect(fetcher.aggregated_transactions.count).to eq(5)
      expect(fetcher.aggregated_transactions.total_spend).to eq(700)
    end

    it 'queries transactions for the past week' do
      fetcher = TransactionsFetcher.call(@company, Stat::WEEKLY, params)
      expect(fetcher.aggregated_transactions.count).to eq(2)
      expect(fetcher.aggregated_transactions.total_spend).to eq(0)
    end

    it 'queries transactions for the past month' do
      fetcher = TransactionsFetcher.call(@company, Stat::MONTHLY, params)
      expect(fetcher.aggregated_transactions.count).to eq(3)
      expect(fetcher.aggregated_transactions.total_spend).to eq(100)
    end

    it 'queries transactions for the past 3 months' do
      fetcher = TransactionsFetcher.call(@company, Stat::QUARTERLY, params)
      expect(fetcher.aggregated_transactions.count).to eq(4)
      expect(fetcher.aggregated_transactions.total_spend).to eq(200)
    end

    it 'queries transactions for the past year' do
      fetcher = TransactionsFetcher.call(@company, Stat::YEARLY, params)
      expect(fetcher.aggregated_transactions.count).to eq(5)
      expect(fetcher.aggregated_transactions.total_spend).to eq(700)
    end
  end

  private

  def build_historical_transactions
    create(:transaction, occured_at: Date.today, amount: -100, user: @user, category: @category_1,
      description: 'Amazon.com', bank_account: @bank_account_1)
    create(:transaction, occured_at: Date.today, amount: 100, user: @user, category: @category,
      description: 'Doordash', bank_account: @bank_account)
    create(:transaction, occured_at: Date.today, amount: 100, user: @user, essential: false, description: 'Starbucks', bank_account: @bank_account)
    create(:transaction, occured_at: 1.month.ago, amount: 100, user: @user,
      description: 'Amazon Tips*2HTSK0EL3', bank_account: @bank_account, category: @category,)
    create(:transaction, occured_at: 3.month.ago, amount: 100, user: @user,
      description: 'Amazon Tips*2HTSK0EL3', bank_account: @bank_account, category: @category_1)
    create(:transaction, occured_at: 4.month.ago, amount: 400, user: @user, description: 'Amazon Tips*2HTSK0EL3', bank_account: @bank_account)
    create(:transaction, occured_at: 1.year.ago, amount: 500, user: @user,
      description: 'Amazon Tips*2HTSK0EL3', bank_account: @bank_account, category: @category)
  end
end
