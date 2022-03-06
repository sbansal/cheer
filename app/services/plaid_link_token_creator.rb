class PlaidLinkTokenCreator < ApplicationService

  def initialize(user_id, access_token=nil, update_mode=false)
    @client_user_id = user_id
    @access_token = access_token
    @update_mode = update_mode
  end

  def call
    PlaidClientCreator.call.link_token_create(link_token_create_request)
  end

  private

  def link_token_create_request
    if @update_mode
      Plaid::LinkTokenCreateRequest.new(
        {
          user: {
            client_user_id: "#{@client_user_id}-user-id",
          },
          client_name: Rails.application.credentials[:plaid][:client_name],
          country_codes: Rails.application.credentials[:plaid][:country_codes],
          language: Rails.application.credentials[:plaid][:language],
          webhook: Rails.application.credentials[:login_item_webhook],
          access_token: @access_token,
          redirect_uri: Rails.application.credentials[:plaid][:redirect_uri],
        }
      )
    else
      Plaid::LinkTokenCreateRequest.new(
        {
          user: {
            client_user_id: "#{@client_user_id}-user-id",
          },
          client_name: Rails.application.credentials[:plaid][:client_name],
          country_codes: Rails.application.credentials[:plaid][:country_codes],
          language: Rails.application.credentials[:plaid][:language],
          webhook: Rails.application.credentials[:login_item_webhook],
          products: Rails.application.credentials[:plaid][:products],
          redirect_uri: Rails.application.credentials[:plaid][:redirect_uri],
        }
      )
    end
  end
end