class GenericMailer < ApplicationMailer
  def invite_person_email(user_id, invitee_name)
    @user = User.find(user_id)
    @token = @user.regenerate_password_token
    @invitee_name = invitee_name
    mail(:to =>  @user.email, :subject => "Welcome! #{@invitee_name} has invited you to their Cheer account.")
  end
end
