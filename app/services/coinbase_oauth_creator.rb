class CoinbaseOAuthCreator
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

  def retrieve_access_token(temp_code, user)
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
    login_item.update(
      oauth_access_token: response['access_token'],
      oauth_refresh_token: response['refresh_token'],
    )
    login_item
  end

  def institution
    Institution.find_by_name(COINBASE_OAUTH_PROVIDER.capitalize)
  end
end
