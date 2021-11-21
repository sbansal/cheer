class CoinbaseClientCreator < ApplicationService
  require 'coinbase/wallet'

  def initialize(access_token, refresh_token)
    @access_token = access_token
    @refresh_token = refresh_token
  end

  def call
    Coinbase::Wallet::OAuthClient.new(access_token: @access_token, refresh_token: @refresh_token)
  end
end