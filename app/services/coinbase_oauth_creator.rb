require 'coinbase/wallet'
class CoinbaseOauthCreator
  AUTHORIZATION_CODE = 'authorization_code'
  COINBASE_OAUTH_PROVIDER = 'coinbase'

  def initialize
    @coinbase_client_id = Rails.application.credentials[:coinbase][:client_id]
    @coinbase_client_secret = Rails.application.credentials[:coinbase][:client_secret]
    @state = Rails.application.credentials[:coinbase][:state]
  end

  def oauth_url
    url = 'https://www.coinbase.com/oauth/authorize?response_type=code&scope=wallet:accounts:read'
    url = url + "&client_id=#{@coinbase_client_id}&state=#{@state}"
  end

  def valid_state?(state)
    @state == state
  end

  def update_login_item(temp_code, user)
    options = {
      body: {
        code: temp_code,
        grant_type: AUTHORIZATION_CODE,
        client_id: @coinbase_client_id,
        client_secret: @coinbase_client_secret,
        redirect_uri: 'https://app.usecheer.test/oauth/callback',
      }
    }
    Rails.logger.info("Options = #{options}")
    response = HTTParty.post('https://api.coinbase.com/oauth/token', options)
    Rails.logger.info("Response = #{response}")
    login_item = user.login_items.find_or_initialize_by(
      institution_id: institution.id,
      oauth_provider: COINBASE_OAUTH_PROVIDER,
    )
    login_item.update_oauth_info(response)
    CoinbaseAccountsCreator.call(login_item)
    login_item
  end

  def create_accounts(login_item)
    client = CoinbaseDataProvider.new(login_item.oauth_access_token, login_item.oauth_refresh_token)
    accounts_array = client.accounts
    BankAccount.create_from_params(accounts_array_json, login_item.id, @user.id, login_item.institution_id)
  end

  def revoke_token(access_token, refresh_token)
    Coinbase::Wallet::OAuthClient.new(
      access_token: access_token,
      refresh_token: refresh_token,
    ).revoke!
  end

  def institution
    Institution.find_by_name(COINBASE_OAUTH_PROVIDER.capitalize)
  end

  def refresh_tokens(login_item)
    response = Coinbase::Wallet::OAuthClient.new(
      access_token: login_item.oauth_access_token,
      refresh_token: login_item.oauth_refresh_token,
    ).refresh!
    login_item.update_oauth_info(response)
    Rails.logger.info("Updated the access token for coinbase login item #{login_item.id}")
  end
end

