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

  def customer_subscription_created_notification(user_id)
    @user = User.find(user_id)
    mail(to: @user.email, subject: "Thank you for subscribing to Cheer premium.")
  end

  def customer_subscription_deleted_notification(subscription_id, user_id)
    @user = User.find(user_id)
    @subscription = StripeSubscriptionFetcher.call(subscription_id)
    mail(to: @user.email, subject: "Your Cheer subscription is canceled.")
  end
end
