class AccountsController < ApplicationController
  def settings
  end

  def cashflow_trend
    assets_trend = current_account.assets_trend
    liabilities_trend = current_account.liabilities_trend
    respond_to do |format|
      format.json { render json: { assets_trend: assets_trend, liabilities_trend: liabilities_trend } }
    end
  end
end
