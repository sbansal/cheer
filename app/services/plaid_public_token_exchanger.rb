class PlaidPublicTokenExchanger < ApplicationService
  def initialize(public_token)
    @public_token = public_token
    @client = PlaidClientCreator.call
  end
  
  def call
    request = Plaid::ItemPublicTokenExchangeRequest.new({ public_token: @public_token })
    response = @client.item_public_token_exchange(request)
    response.access_token
  end
end