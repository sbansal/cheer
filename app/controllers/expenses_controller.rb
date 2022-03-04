class ExpensesController < ApplicationController
  def index
    @start_date, @end_date = parse_time_boundary(params)
    @essential_spend_by_categories = current_account.essential_spend_by_categories(@start_date, @end_date)
    @non_essential_spend_by_categories = current_account.non_essential_spend_by_categories(@start_date, @end_date)
  end
end
