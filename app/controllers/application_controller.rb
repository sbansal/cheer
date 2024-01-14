class ApplicationController < ActionController::Base
  before_action :authenticate_user!, :check_product_type
  protect_from_forgery with: :exception
  before_action :configure_permitted_parameters, if: :devise_controller?

  layout :layout_by_resource

  def after_sign_in_path_for(resource)
    if personal_product?
      personal_index_path
    elsif current_user.new_company?
      root_path
    else
      stored_location_for(resource) || root_path
    end
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up) { |u| u.permit(:full_name, :email, :password, :avatar)}
    devise_parameter_sanitizer.permit(:company_update) {
      |u| u.permit(:full_name, :email, :password, :current_password, :password_confirmation, :avatar, :time_zone)
    }
  end

  def check_product_type
    if personal_product?
      if request.path == '/logout'
        return
      elsif request.path != '/personal'
        return
        # redirect_to personal_path
      end
    end
  end

  def current_company
    current_user.company
  end

  def parse_time_boundary(params)
    start_date = params[:start_date] ? Date.parse(params[:start_date]) : Date.today
    end_date = params[:end_date] ? Date.parse(params[:end_date]) : Date.today
    case params[:period]
    when Stat::THIS_MONTH
      start_date = start_date.beginning_of_month
    when Stat::LAST_MONTH
      start_date = (start_date - 1.month).beginning_of_month
      end_date = start_date.end_of_month
    when Stat::MONTHLY
      start_date = start_date - 1.month
    when Stat::QUARTERLY
      start_date = start_date - 3.month
    when Stat::YEARLY
      start_date = start_date - 1.year
    when Stat::ALL
      start_date = current_company.first_transaction_occured_at
    end
    Rails.logger.info("start = #{start_date}, end = #{end_date}")
    return start_date, end_date
  end

  def compute_stat_value_for_period(stat, period)
    if value_over_time_data = current_company.stats.find_by(name: stat)&.value_over_time_data
      value_over_time_data[period] || 0
    else
      0
    end
  end

  private

  def personal_product?
    current_user && current_company.personal_product?
  end

  def layout_by_resource
    if devise_controller?
      "devise"
    elsif current_user && current_company.personal_product?
      "intro"
    else
      "application"
    end
  end
end
