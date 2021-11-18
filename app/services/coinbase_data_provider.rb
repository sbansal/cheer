class CoinbaseBalanceProvider < ApplicationService
  def initialize
    @client = CoinbaseClientCreator.call
  end
  
  def call
    
  end

end