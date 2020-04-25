class LoginItemsController < ApplicationController
  def index
    @login_items = current_user.login_items
  end
  
  def refresh_transactions
    @login_item = current_user.login_items.find(params[:id])
    PlaidTransactionsCreator.call(
      @login_item.plaid_access_token, 
      current_user,
      @login_item.last_transaction_pulled_at.iso8601,
      Date.today.iso8601
    )
    redirect_to login_items_url
  end

  def destroy
    @login_item = current_user.login_items.find(params[:id])
    @login_item.destroy
    respond_to do |format|
      format.html { redirect_to login_items_path }
      format.json { head :no_content }
    end
  end
end
