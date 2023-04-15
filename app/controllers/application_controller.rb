class ApplicationController < ActionController::Base
  before_action :authenticate_user!, :check_product_type
  protect_from_forgery with: :exception
  before_action :configure_permitted_parameters, if: :devise_controller?

  layout :layout_by_resource

  def after_sign_in_path_for(resource)
    if current_company.personal_product?
      export_path
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
    # if current_user && current_company.personal_product? && request.path != '/personal'
    #   redirect_to personal_path
    # end
  end

  def current_company
    current_user.company
  end

  def parse_time_boundary(params)
    start_date = Date.today
    end_date = Date.today
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
    else
      start_date = start_date - 7.days
    end
    Rails.logger.info("start = #{start_date}, end = #{end_date}")
    return start_date, end_date
  end

  private


  def layout_by_resource
    if devise_controller?
      "devise"
    elsif current_company.personal_product?
      "personal"
    else
      "application"
    end
  end
end
