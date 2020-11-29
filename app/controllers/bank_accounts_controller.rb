class BankAccountsController < ApplicationController
  def index
    @asset_accounts = current_account.bank_accounts.assets.includes([login_item: [:institution]])
    @liability_accounts = current_account.bank_accounts.liabilities.includes([login_item: [:institution]])
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

  private

  def account_params
    params.permit(:name, :account_type, :account_subtype, :balance, :account_category)
  end
end
