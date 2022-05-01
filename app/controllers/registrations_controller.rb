class RegistrationsController < Devise::RegistrationsController

  def edit
    redirect_to(settings_path)
  end

  protected

  def after_update_path_for(resource)
    settings_path
  end
end
