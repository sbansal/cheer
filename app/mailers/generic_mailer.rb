class GenericMailer < ApplicationMailer
  def invite_person_email(user_id, invitee_name)
    @user = User.find(user_id)
    @token = @user.regenerate_password_token
    @invitee_name = invitee_name
    mail(:to =>  @user.email, :subject => "Welcome! #{@invitee_name} has invited you to their Cheer account.")
  end

  def two_factor_auth_notification(user_id)
    @user = User.find(user_id)
    mail(:to =>  @user.email, :subject => "Two Factor authentication turned #{@user.two_factor_status} for your Cheer account.")
  end

  def login_item_expired_notification(user_id, login_item_id)
    @user = User.find(user_id)
    @login_item = LoginItem.find(login_item_id)
    @institution_name = @login_item.institution.name
    mail(:to =>  @user.email, :subject => "Cheer is unable to connect to your #{@institution_name} account.")
  end

  def login_item_activated_notification(user_id, login_item_id)
    @user = User.find(user_id)
    @login_item = LoginItem.find(login_item_id)
    @institution_name = @login_item.institution.name
    mail(:to =>  @user.email, :subject => "Successfully connected to your #{@institution_name} account.")
  end

  def new_accounts_available_notification(user_id, login_item_id)
    @user = User.find(user_id)
    @login_item = LoginItem.find(login_item_id)
    @institution_name = @login_item.institution.name
    mail(:to =>  @user.email, :subject => "Cheer - Updated account information available for your #{@institution_name} account.")
  end
end
