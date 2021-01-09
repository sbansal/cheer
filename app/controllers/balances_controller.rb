class BalancesController < ApplicationController
  def index
    @balances = current_account.bank_accounts.find(params[:bank_account_id]).balances
    respond_to do |format|
      format.js
    end
  end
end
