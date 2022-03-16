class Categories::TransactionsController < ApplicationController
  include Pagy::Backend
  def index
    @period = params[:period] || Stat::ALL
    @period_description = Stat::SUPPORTED_PERIODS[@period]
    @start_date, @end_date = parse_time_boundary(params)
    @category = Category.find(params[:category_id])
    @category_name = params[:category_name]
    params[:categories] = [@category.id]
    transactions_fetcher = TransactionsFetcher.call(current_account, @period, params)
    @total_spend = transactions_fetcher.aggregated_transactions.total_spend
    @count = transactions_fetcher.aggregated_transactions.count
    @transactions = transactions_fetcher.aggregated_transactions&.transactions.includes([:bank_account])
  end
end