class PlaidController < ApplicationController
  def index
  end

  def get_access_token
    @client = PlaidClientCreator.call
    @exchange_token_response = @client.item.public_token.exchange(params['public_token'])
    @access_token = @exchange_token_response['access_token']
    PlaidLoginItemCreator.call(@access_token, current_user)
  end
end
