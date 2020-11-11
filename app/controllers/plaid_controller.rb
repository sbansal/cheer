class PlaidController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:update_link, :generate_access_token, :create_link_token]

  def update_link
    @login_item = current_user.login_items.find_by(public_token: params[:public_token])
    @login_item.activate
    redirect_to login_items_path
  end

  def generate_access_token
    @client = PlaidClientCreator.call
    @exchange_token_response = @client.item.public_token.exchange(params['public_token'])
    @access_token = @exchange_token_response['access_token']
    PlaidLoginItemCreator.call(@access_token, current_user)
  end

  def create_link_token
    link_token = PlaidLinkTokenCreator.call(current_user.id)
    respond_to do |format|
      format.json { render json: {link_token: link_token} }
    end
  end
end
