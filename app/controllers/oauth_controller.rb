class OauthController < ApplicationController
  def callback
    state = params[:state]
    @coinbase_client = CoinbaseOauthCreator.new
    if state && @coinbase_client.valid_state?(state)
      login_item = @coinbase_client.update_login_item(params[:code], current_user)
      flash[:notice_header] = 'New link created'
      flash[:notice] = "You have successfully linked your #{login_item.institution.name} accounts to Cheer."
    else
      Rails.logger.error("Unable to link coinbase account.")
    end
    respond_to do |format|
      format.html { redirect_to login_items_path }
    end
  end
end