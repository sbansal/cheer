class ZillowRealEstateDataProcessor < ApplicationService
  include HTTParty
  attr_reader :account
  base_uri 'zillow.com/webservice/GetSearchResults.htm'

  def initialize(account_id)
    @account = BankAccount.find(account_id)
    if @account.real_estate?
      zillow_wsid = Rails.application.credentials[:zillow][:wsid]
    else
      Rails.logger.error("Real estate data can only be processed for non real estate account - #{@account.inspect}")
    end
  end
end