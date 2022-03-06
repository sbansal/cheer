class PlaidClientCreator < ApplicationService

  def call
    configuration = Plaid::Configuration.new
    env = Rails.application.credentials[:plaid][:environment]
    configuration.server_index = Plaid::Configuration::Environment[env]
    configuration.api_key["PLAID-CLIENT-ID"] = Rails.application.credentials[:plaid][:client_id]
    configuration.api_key["PLAID-SECRET"] = Rails.application.credentials[:plaid][:secret]

    api_client = Plaid::ApiClient.new(
      configuration
    )
    Plaid::PlaidApi.new(api_client)
  end
end