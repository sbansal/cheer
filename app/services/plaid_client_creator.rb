class PlaidClientCreator < ApplicationService
  require 'plaid'

  def call
    Plaid::Client.new(
      env: Rails.application.credentials[:plaid][:environment],
      client_id: Rails.application.credentials[:plaid][:client_id],
      secret: Rails.application.credentials[:plaid][:secret],
    )
  end
end