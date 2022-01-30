class BalancesController < ApplicationController
  def index
    balance_data = current_account.bank_accounts.find(params[:bank_account_id])&.balances.map { |balance| [balance.updated_at.end_of_day, balance.current] }.sort.to_h
    @balances = HistoricalTrendCalculator.call(balance_data)
    respond_to do |format|
      format.js
      format.json { render json: { balances: @balances }}
    end
  end
end
