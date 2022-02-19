class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  protect_from_forgery with: :exception
  before_action :configure_permitted_parameters, if: :devise_controller?

  layout :layout_by_resource

  def after_sign_in_path_for(resource)
    if current_user.new_account?
      root_path
    else
      stored_location_for(resource) || root_path
    end
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up) { |u| u.permit(:full_name, :email, :password, :avatar)}
    devise_parameter_sanitizer.permit(:account_update) {
      |u| u.permit(:full_name, :email, :password, :current_password, :password_confirmation, :avatar, :time_zone)
    }
  end

  def current_account
    current_user.account
  end

  def parse_time_boundary(params)
    start_date = Time.zone.now.beginning_of_month
    end_date = Time.zone.now
    case params[:period]
    when Stat::MONTHLY
      start_date = start_date - 1.month
    when Stat::QUARTERLY
      start_date = start_date - 3.month
    when Stat::YEARLY
      start_date = start_date - 1.year
    when Stat::ALL
      start_date = current_account.first_transaction_occured_at
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
    else
      "application"
    end
  end
end
