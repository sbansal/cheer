class AccountsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:new, :create]
  def settings
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

    respond_to do |format|
      if @account.save
        sign_in(:user, @user)
      else
        format.html { render action: "new", layout: 'devise'}
      end
    end
  end

  private

  def account_params
    params.require(:account).permit(:name, users_attributes: [:full_name, :email, :password])
  end
end
