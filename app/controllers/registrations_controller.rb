class RegistrationsController < Devise::RegistrationsController

  def edit
    redirect_to(accounts_settings_path)
  end

  protected

  def after_update_path_for(resource)
    accounts_settings_path
  end
end
