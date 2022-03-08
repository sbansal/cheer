class LoginItemsController < ApplicationController
  def index
    @login_items = current_account.login_items.includes([:institution, :user])
  end

  def show
    @login_item = current_account.login_items.find(params[:id])
    client = PlaidClientCreator.call
    response = client.item_get(Plaid::ItemGetRequest.new({ access_token: @login_item.plaid_access_token }))
    @item_status = response.status
    @item_metadata = response.item
    respond_to do |format|
      format.json { render json: {item: @item_metadata, item_status: @item_status} }
    end
  end

  def refresh_transactions
    @login_item = current_account.login_items.find(params[:id])
    begin
      PlaidTransactionsCreator.call(
        @login_item.plaid_access_token,
        current_user,
        current_user.last_transaction_pulled_at.iso8601,
        Date.today.iso8601
      )
    rescue Plaid::ItemError => e
      Rails.logger.error(e)
      if e.error_code == 'ITEM_LOGIN_REQUIRED'
        @login_item.expire
      end
    end
    redirect_to login_items_url
  end

  def refresh_historical_transactions
    @login_item = current_account.login_items.find(params[:id])
    begin
      end_date = @login_item.transactions_history_period[0] || Date.today
      PlaidTransactionsCreator.call(
        @login_item.plaid_access_token,
        current_user,
        (end_date - 3.month).iso8601,
        end_date.iso8601,
      )
    rescue Plaid::ItemError => e
      Rails.logger.error(e)
      if e.error_code == 'ITEM_LOGIN_REQUIRED'
        @login_item.expire
      end
    end
    redirect_to login_items_url
  end

  def destroy
    @login_item = current_account.login_items.find(params[:id])
    begin
      response = PlaidLinkDeleter.call(@login_item.plaid_access_token)
      @login_item.destroy
      StatsCreatorJob.perform_later(current_account.id)
      respond_to do |format|
        format.html { redirect_to login_items_path }
        format.json { head :no_content }
      end
    rescue => e
      Rails.logger.error("Error destroying login item")
      Rails.logger.error(e)
      flash[:alert_header] = 'Link could not be deleted.'
      flash[:alert] = "We were not able to remove #{@login_item.institution.name} link from Cheer. Please try again."
      respond_to do |format|
        format.html { redirect_to login_items_path, flash: { error: 'Link could not be deleted.' } }
        format.json { head :unprocessable_entity }
      end
    end
  end
end
