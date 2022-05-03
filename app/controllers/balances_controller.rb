class BalancesController < ApplicationController
  def index
    @period = params[:period] || Stat::THIS_MONTH
    @start_date, @end_date = parse_time_boundary(params)
    bank_account = current_company.bank_accounts.find(params[:bank_account_id])
    balance_data = bank_account&.balances.where(created_at: @start_date.to_datetime.end_of_day.utc..@end_date.to_datetime.end_of_day.utc).map {
      |balance| [balance.updated_at.end_of_day, balance.current]
    }.sort.to_h
    @balances = HistoricalTrendCalculator.call(balance_data)
    respond_to do |format|
      format.js
      format.json { render json: { balances: @balances }}
    end
  end
end
