class ExpensesController < ApplicationController
  def index
    @start_date, @end_date = parse_params(params)
    @essential_spend_by_categories = current_account.essential_spend_by_categories(@start_date, @end_date)
    @non_essential_spend_by_categories = current_account.non_essential_spend_by_categories(@start_date, @end_date)
  end
  
  private
  
  def parse_params(params)
    start_date = Time.zone.now.beginning_of_month
    end_date = Time.zone.now
    start_date = Time.zone.parse(params[:start]) if params[:start]
    end_date = Time.zone.parse(params[:end]) if params[:end]
    return start_date, end_date
  end
end