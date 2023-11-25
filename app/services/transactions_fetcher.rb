class TransactionsFetcher < ApplicationService
  attr_reader :aggregated_transactions, :start_date, :end_date, :duplicates_count
  def initialize(company, period, params={})
    @company = company
    @initial_scope = @company.transactions.includes(:category)
    @params = params
    calculate_occured_at_boundary(period)
    Rails.logger.info("@start_date, @end_date = #{@start_date}, #{@end_date}")
  end

  def call
    scoped = filter_by_date(@initial_scope)
    scoped = filter_by_search_query(scoped, @params[:search_query]) if @params[:search_query].present?
    scoped = filter_by_bank_accounts(scoped, @params[:bank_account_id]) if @params[:bank_account_id].present?
    scoped = filter_by_categories(scoped, @params[:categories]) if @params[:categories].present?
    scoped = filter_by_duplicate_transactions(scoped) if @params[:show_duplicates] == 'true'
    @duplicates_count = duplicates_count(scoped)

    OpenStruct.new(
      aggregated_transactions: Transaction::AggregatedTransactions.new('transactions', scoped),
      start_date: @start_date,
      end_date: @end_date,
      duplicates_count: @duplicates_count || 0,
    )
  end

  private

  def filter_by_date(scoped)
    scoped.where(occured_at: @start_date..@end_date)
  end

  def filter_by_search_query(scoped, query)
    wildcard_query = "%#{query}%"
    scoped.where('custom_description ILIKE ? OR description ILIKE ? OR merchant_name ILIKE ?', wildcard_query, wildcard_query, wildcard_query)
  end

  def filter_by_bank_accounts(scoped, bank_account_ids=[])
    scoped.where(bank_account_id: bank_account_ids)
  end

  def filter_by_categories(scoped, category_ids=[])
    scoped.where(category: category_ids)
  end

  def filter_by_duplicate_transactions(scoped)
    scoped.where(duplicate: true)
  end

  def duplicates_count(scoped)
    scoped.where(duplicate: true).count
  end

  def calculate_occured_at_boundary(period)
    @start_date = @params[:start_date] ? Date.parse(@params[:start_date]) : Date.today
    @end_date = @params[:end_date] ? Date.parse(@params[:end_date]) : Date.today
    case period
    when Stat::THIS_MONTH
      @start_date = start_date.beginning_of_month
    when Stat::LAST_MONTH
      @start_date = (start_date - 1.month).beginning_of_month
      @end_date = start_date.end_of_month
    when Stat::WEEKLY
      @start_date = start_date - 7.days
    when Stat::MONTHLY
      @start_date = start_date - 1.month
    when Stat::QUARTERLY
      @start_date = start_date - 3.month
    when Stat::YEARLY
      @start_date = start_date - 1.year
    when Stat::ALL
      @start_date = @company.first_transaction_occured_at
    end
  end
end
