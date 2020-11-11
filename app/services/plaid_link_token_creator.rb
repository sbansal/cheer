class PlaidLinkTokenCreator < ApplicationService
  
  def initialize(user_id)
    @client_user_id = user_id
  end

  def call
    @client = PlaidClientCreator.call
    response = @client.link_token.create(
      user: {
        client_user_id: @client
      },
      client_name: Rails.application.credentials[:plaid][:client_name],
      products: Rails.application.credentials[:plaid][:products],
      country_codes: Rails.application.credentials[:plaid][:country_codes],
      language: Rails.application.credentials[:plaid][:language],
      webhook: Rails.application.credentials[:login_item_webhook],
    )
    link_token = response['link_token']
  end
end