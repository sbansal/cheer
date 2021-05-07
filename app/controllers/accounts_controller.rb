class AccountsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:new, :create]

  def settings
    respond_to do |format|
      format.html
    end
  end

  def cashflow_trend
    assets_trend = current_account.stats.find_by(name: Stat::ASSETS_STAT).historical_trend_data
    liabilities_trend = current_account.stats.find_by(name: Stat::LIABILITIES_STAT).historical_trend_data
    respond_to do |format|
      format.json { render json: { assets_trend: assets_trend, liabilities_trend: liabilities_trend } }
    end
  end

  def income_expense_trend
    income_trend = {
      "2021-01-10T00:00:00+00:00":10000,
      "2021-02-11T00:00:00+00:00":10000,
      "2021-03-10T00:00:00+00:00":12000,
      "2021-04-11T00:00:00+00:00":13000,
      "2021-05-11T00:00:00+00:00":9000,
      "2021-06-11T00:00:00+00:00":15000,
      # "2021-07-10T00:00:00+00:00":10000,
      # "2021-08-11T00:00:00+00:00":10000,
      # "2021-09-10T00:00:00+00:00":12000,
      # "2021-10-11T00:00:00+00:00":13000,
      # "2021-11-11T00:00:00+00:00":9000,
      # "2021-12-11T00:00:00+00:00":15000,
    }
    expense_trend = {
      "2021-01-10T00:00:00+00:00":5000,
      "2021-02-11T00:00:00+00:00":5000,
      "2021-03-10T00:00:00+00:00":6000,
      "2021-04-11T00:00:00+00:00":9000,
      "2021-05-11T00:00:00+00:00":5000,
      "2021-06-11T00:00:00+00:00":12500,
      # "2021-07-10T00:00:00+00:00":4000,
      # "2021-08-11T00:00:00+00:00":5000,
      # "2021-09-10T00:00:00+00:00":16000,
      # "2021-10-11T00:00:00+00:00":6000,
      # "2021-11-11T00:00:00+00:00":800,
      # "2021-12-11T00:00:00+00:00":21000,
    }
    saving_trend = {
      "2021-01-10T00:00:00+00:00":5000,
      "2021-02-11T00:00:00+00:00":5000,
      "2021-03-10T00:00:00+00:00":6000,
      "2021-04-11T00:00:00+00:00":4000,
      "2021-05-11T00:00:00+00:00":4000,
      "2021-06-11T00:00:00+00:00":2500,
      # "2021-07-10T00:00:00+00:00":6000,
      # "2021-08-11T00:00:00+00:00":5000,
      # "2021-09-10T00:00:00+00:00":-4000,
      # "2021-10-11T00:00:00+00:00":3000,
      # "2021-11-11T00:00:00+00:00":100,
      # "2021-12-11T00:00:00+00:00":-6000,
    }
    respond_to do |format|
      format.json { render json: { income_trend: income_trend, expense_trend: expense_trend, saving_trend: saving_trend } }
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
