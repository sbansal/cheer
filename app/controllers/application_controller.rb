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
    devise_parameter_sanitizer.permit(:account_update) { |u| u.permit(:full_name, :email, :password, :current_password, :password_confirmation, :avatar)}
  end

  def current_account
    current_user.account
  end

  private

  def layout_by_resource
    if devise_controller?
      "devise"
    elsif user_signed_in? && current_user.new_account?
      "intro"
    else
      "application"
    end
  end
end
