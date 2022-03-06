class PlaidLinkDeleter < ApplicationService
  def initialize(access_token)
    @client = PlaidClientCreator.call
    @access_token = access_token
  end

  def call
    begin
      request = Plaid::ItemRemoveRequest.new({ access_token: @access_token })
      response = @client.item_remove(request)
    rescue Plaid::ApiError => e
      Rails.logger.error(e)
      if invalid_access_token_error?(e)
        Rails.logger.warn("Ignoring the error, and removing invalid access.")
      else
        raise e
      end
    rescue => e
      Rails.logger.error(e)
      raise e
    end
  end

  private
  PLAID_INVALID_ACCESS_TOKEN_ERROR_CODE = 'INVALID_ACCESS_TOKEN'
  PLAID_INVALID_ACCESS_TOKEN_ERROR_MSG = 'could not find matching access token'

  def invalid_access_token_error?(error)
    error_body = OpenStruct.new(JSON.parse(error.response_body))
    error_body.error_code == PLAID_INVALID_ACCESS_TOKEN_ERROR_CODE && error_body.error_message == PLAID_INVALID_ACCESS_TOKEN_ERROR_MSG
  end
end
