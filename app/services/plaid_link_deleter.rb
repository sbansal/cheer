class PlaidLinkDeleter < ApplicationService
  def initialize(access_token)
    @client = PlaidClientCreator.call
    @access_token = access_token
  end

  def call
    request = Plaid::ItemRemoveRequest.new({ access_token: @access_token })
    response = @client.item_remove(request)
  end

end