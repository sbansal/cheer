class PlaidPublicTokenCreator < ApplicationService
  def initialize(plaid_access_token)
    @client = PlaidClientCreator.call
    @access_token = plaid_access_token
  end

  def call
    @client.item.public_token.create(@access_token)
  end

end