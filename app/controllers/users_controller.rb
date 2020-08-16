class UsersController < ApplicationController
  def index
    @users = User.all
  end

  def invite_person
    @user = current_account.users.build
    @user.invite_person(params[:email], params[:full_name])
    if @user.save
      @user.send_invitation_message(current_user.full_name)
      redirect_to(accounts_settings_path, notice: "An invitation has been sent to #{@user.email}.")
    else
      redirect_to(accounts_settings_path, :flash => { :error => @user.errors.full_messages })
    end
  end

  def reinvite
    @user = User.find(params[:id])
    @user.send_invitation_message(current_user.full_name)
    redirect_to(accounts_settings_path, notice: "An invitation has been sent to #{@user.email}.")
  end
end
