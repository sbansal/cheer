class AccountsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:new, :create]

  def settings
    respond_to do |format|
      format.html
    end
  end

  def cashflow_trend
    assets_trend = current_account.assets_trend
    liabilities_trend = current_account.liabilities_trend
    respond_to do |format|
      format.json { render json: { assets_trend: assets_trend, liabilities_trend: liabilities_trend } }
    end
  end

  def new
    @account = Account.new(name: 'New Account')
    @user = @account.users.build
    respond_to do |format|
      format.html { render layout: 'devise' }
    end
  end

  def create
    @account = Account.new(account_params)
    @user = @account.users.first
    @account.name = "#{@user.full_name} Account"
    @user.account_owner = true
    Rails.logger.info("Creating account with params = #{@account.inspect} and @user = #{@user.inspect}")

    if @account.save
      flash[:notice_header] = 'Account successfully created.'
      flash[:notice] = 'We sent a confirmation link to your email address. Please follow the link to activate your account.'
      redirect_to new_user_session_path
    else
      respond_to do |format|
        format.html { render action: "new", layout: 'devise'}
      end
    end

  end

  private

  def account_params
    params.require(:account).permit(:name, users_attributes: [:full_name, :email, :password])
  end
end
