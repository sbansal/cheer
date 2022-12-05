class ApplicationService
  def self.call(*args, &block)
    new(*args, &block).call
  end

  protected
  ITEM_LOGIN_REQUIRED = 'ITEM_LOGIN_REQUIRED'

  def item_expired?(error)
    error_body = OpenStruct.new(JSON.parse(error.response_body))
    error_body.error_code == ITEM_LOGIN_REQUIRED
  end
end