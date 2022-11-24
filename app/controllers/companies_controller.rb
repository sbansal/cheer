class CompaniesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:new, :create]

  def settings
    @notification_templates = NotificationTemplate.all
    respond_to do |format|
      format.html
    end
  end

  def cashflow_trend
    @start_date, @end_date = parse_time_boundary(params)
    assets_trend = HistoricalTrendCalculator.call(
      current_company.stats.find_by(name: Stat::ASSETS_STAT).sanitized_historical_trend_data_between(@start_date, @end_date)
    )
    liabilities_trend = HistoricalTrendCalculator.call(
      current_company.stats.find_by(name: Stat::LIABILITIES_STAT).sanitized_historical_trend_data_between(@start_date, @end_date)
    )
    respond_to do |format|
      format.json { render json: { assets_trend: assets_trend, liabilities_trend: liabilities_trend } }
    end
  end

  def income_expense_trend
    @start_date, @end_date = parse_time_boundary(params)
    income_trend = HistoricalTrendAggregator.call(
      current_company.stats.find_by_name(Stat::INCOME_STAT).sanitized_historical_trend_data_between(@start_date, @end_date)
    )
    expense_trend = HistoricalTrendAggregator.call(
      current_company.stats.find_by_name(Stat::EXPENSES_STAT).sanitized_historical_trend_data_between(@start_date, @end_date)
    )
    saving_trend = HistoricalTrendAggregator.call(
      current_company.stats.find_by_name(Stat::SAVINGS_STAT).sanitized_historical_trend_data_between(@start_date, @end_date)
    )

    respond_to do |format|
      format.json { render json: { income_trend: income_trend, expense_trend: expense_trend, saving_trend: saving_trend } }
    end
  end

  def new
    @company = Company.new(name: 'New Account')
    @user = @company.users.build
    respond_to do |format|
      format.html { render layout: 'devise' }
    end
  end

  def create
    @company = Company.new(company_params)
    @user = @company.users.first
    @company.name = "#{@user.full_name} Account"
    @user.account_owner = true
    Rails.logger.info("Creating company with params = #{@company.inspect} and @user = #{@user.inspect}")

    if @company.save
      flash[:notice_header] = 'Cheer account successfully created.'
      flash[:notice] = 'We sent a confirmation link to your email address. Please follow the link to activate your Cheer account.'
      redirect_to new_user_session_path
    else
      respond_to do |format|
        format.html { render action: "new", layout: 'devise'}
      end
    end

  end

  private

  def company_params
    params.require(:company).permit(:name, users_attributes: [:full_name, :email, :password])
  end
end
