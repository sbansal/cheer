class UsersController < ApplicationController
  def index
    @users = User.all
  end

  def invite_person
    @user = current_company.users.build
    @user.invite_person(params[:email], params[:full_name])
    if @user.save
      @user.send_invitation_message(current_user.full_name)
      flash[:notice_header] = 'Invitation sent.'
      flash[:notice] = "We have invited #{@user.full_name} to your cheer account."
      redirect_to(settings_path)
    else
      flash[:alert_header] = 'Invite not sent.'
      flash[:alert] = "An account with this email address already exists."
      redirect_to(settings_path)
    end
  end

  def reinvite
    @user = User.find(params[:id])
    @user.send_invitation_message(current_user.full_name)
    flash[:notice_header] = 'Invitation sent.'
    flash[:notice] = "We have invited #{@user.full_name} to your cheer account."
    redirect_to(settings_path)
  end

  def update
    if user_params[:weekly_summary] && current_user.update(user_params)
      flash[:notice_header] = 'Notification settings updated.'
      flash[:notice] = "You will #{current_user.weekly_summary ? 'now' : 'no longer'} receive a weekly summary of your finances."
      redirect_to(settings_path)
    elsif current_user.update(user_params)
      flash[:notice_header] = 'Profile updated'
      flash[:notice] = "Your profile settings were successfully updated."
      redirect_to(settings_path, notice: "Your profile settings were successfully updated.")
    else
      flash[:alert_header] = 'Profile not updated'
      flash[:alert] = "Your profile settings were not updated. Please check your entries and try again."
      redirect_to(settings_path)
    end
  end

  private

  def user_params
    params.require(:user).permit(:full_name, :email, :time_zone, :weekly_summary)
  end
end
