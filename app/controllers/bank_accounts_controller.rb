class BankAccountsController < ApplicationController
  def index
    @cash_assets = current_account.bank_accounts.includes([:institution]).assets.liquid_accounts
    @non_cash_asset_accounts = current_account.bank_accounts.includes([:institution]).assets.illiquid_accounts
    @liability_accounts = current_account.bank_accounts.includes([:institution]).liabilities
  end

  def refresh
    @bank_account = current_account.bank_accounts.find(params[:id])
    begin
      response = PlaidBalanceProcessor.call(@bank_account.login_item.plaid_access_token)
      respond_to do |format|
        format.html { redirect_to bank_accounts_path, flash: { error: 'Successfully refreshed balances.' } }
        format.json { head :no_content }
      end
    rescue => e
      Rails.logger.error(e)
      respond_to do |format|
        format.html { redirect_to bank_accounts_path, flash: { error: 'Unable to refresh balances.' } }
        format.json { head :unprocessable_entity }
      end
    end
  end

  def destroy
    @bank_account = current_account.bank_accounts.find(params[:id])
    if @bank_account.destroy
      respond_to do |format|
        format.html { redirect_to bank_accounts_path }
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html { redirect_to bank_accounts_path, flash: { error: 'Bank account could not be deleted.' } }
        format.json { head :unprocessable_entity }
      end
    end
  end

  def new
    @account_category = params['account_category'] || 'asset'
    @bank_account = current_user.bank_accounts.new
    @account_types = AccountType.find_all_for_category(@account_category)
    respond_to do |format|
      format.html
      format.js
    end
  end

  def create
    @bank_account = current_user.bank_accounts.build
    @bank_account = @bank_account.create_from_params(account_params)
    respond_to do |format|
      if @bank_account.persisted?
        format.html { redirect_to bank_accounts_path, flash: { notice: "#{@bank_account.name} - added successfully. " } }
      else
        format.html  { render :action => "new" }
      end
    end
  end

  def edit
    @bank_account = current_user.bank_accounts.find(params[:id])
    respond_to do |format|
      format.js
    end
  end

  def show
    @period = params[:period] || Stat::THIS_MONTH
    @start_date, @end_date = parse_time_boundary(params)
    @bank_account = current_account.bank_accounts.find(params[:id])
    fetcher = TransactionsFetcher.call(current_account, @period, params.merge(bank_account_id: [@bank_account.id]))
    @transactions = fetcher.aggregated_transactions&.transactions
    @transactions_by_category = @transactions.group_by(&:category).map {
      |category, transactions| CategorizedTransaction.new(category.name, transactions)
    }.sort_by { |item| item.total_spend }
    @transactions_by_merchant = @transactions.group_by(&:merchant_name).map {
      |merchant_name, transactions| CategorizedTransaction.new(merchant_name, transactions)
    }.sort_by { |item| item.total_spend }
  end

  def update
    @bank_account = current_user.bank_accounts.find(params[:id])
    respond_to do |format|
      if @bank_account.update_from_params(update_account_params)
        format.html { redirect_to bank_accounts_path, flash: { notice: "Balance successfully updated. "} }
        format.js
      else
        format.html  { render :action => "edit" }
      end
    end
  end

  private

  def account_params
    params.permit(:name, :account_type, :account_subtype, :balance, :account_category)
  end

  def update_account_params
    params.require(:bank_account).permit(:current_balance)
  end
end
