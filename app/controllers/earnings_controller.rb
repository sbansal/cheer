class EarningsController < ApplicationController
  def index
    @start_date, @end_date = parse_time_boundary(params)
    @earning_transactions = current_company.money_in_by_categories(@start_date, @end_date)
  end
end
