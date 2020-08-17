class BankAccountsController < ApplicationController
  def index
    @bank_accounts = current_account.bank_accounts.includes([login_item: [:institution]])
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
end
