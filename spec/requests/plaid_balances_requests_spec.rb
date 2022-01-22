require 'rails_helper'
require 'plaid'

RSpec.describe "PlaidBalancesRequests", type: :request do
  describe "GET Plaid transactions" do
    before(:all) do
      setup_plaid_categories
      @access_token = create_plaid_sandbox_link_and_fetch_access_token
      @user = create(:user)
      PlaidLoginItemCreator.call(@access_token, @user)
    end

    it "retries balances" do
      balances = BankAccount.where(user_id: @user.id).map { |acc| acc.balances }
      count = balances.count
      expect(count).to be > 0
      PlaidBalanceProcessor.call(@access_token)
      balances = BankAccount.where(user_id: @user.id).map { |acc| acc.balances }
      count_2 = balances.count
      expect(count_2).to be >= count
    end

    after(:all) do
      Category.delete_all
      User.delete_all
    end
  end
end
