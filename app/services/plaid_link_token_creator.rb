class PlaidLinkTokenCreator < ApplicationService

  def initialize(user_id, access_token=nil, update_mode=false)
    @client_user_id = user_id
    @access_token = access_token
    @update_mode = update_mode
  end

  def call
    @client = PlaidClientCreator.call
    if @update_mode
      response = @client.link_token.create(
        user: {
          client_user_id: "#{@client_user_id}-user-id",
        },
        client_name: Rails.application.credentials[:plaid][:client_name],
        country_codes: Rails.application.credentials[:plaid][:country_codes],
        language: Rails.application.credentials[:plaid][:language],
        webhook: Rails.application.credentials[:login_item_webhook],
        access_token: @access_token,
      )
    else
      response = @client.link_token.create(
        user: {
          client_user_id: "#{@client_user_id}-user-id",
        },
        client_name: Rails.application.credentials[:plaid][:client_name],
        country_codes: Rails.application.credentials[:plaid][:country_codes],
        language: Rails.application.credentials[:plaid][:language],
        webhook: Rails.application.credentials[:login_item_webhook],
        products: Rails.application.credentials[:plaid][:products],
      )
    end
    response
  end
end