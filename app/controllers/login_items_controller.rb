class LoginItemsController < ApplicationController
  def index
    @login_items = current_user.login_items
  end
  
  def refresh_transactions
    @login_item = current_user.login_items.find(params[:id])
    PlaidTransactionsCreator.call(
      @login_item.plaid_access_token, 
      current_user,
      (Date.today.beginning_of_year + 1.month).iso8601,
      (Date.today.beginning_of_year + 2.month).iso8601
    )
    redirect_to login_items_url
  end

  def destroy
    @login_item = current_user.login_items.find(params[:id])
    client = PlaidClientCreator.call
    response = client.item.remove(@login_item.plaid_access_token)
    if response.removed
      @login_item.destroy
      respond_to do |format|
        format.html { redirect_to current_user.login_items.empty? ? root_path : login_items_path }
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html { redirect_to login_items_path, flash: { error: 'Login item could not be deleted.' } }
        format.json { head :unprocessable_entity }
      end
    end
  end
end
