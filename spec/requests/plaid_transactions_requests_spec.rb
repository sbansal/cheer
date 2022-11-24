require 'rails_helper'
require 'plaid'

RSpec.describe "PlaidTransactionsRequests", type: :request do
  describe "GET Plaid transactions" do
    before(:all) do
      setup_plaid_categories
      @access_token = create_plaid_sandbox_link_and_fetch_access_token
      @user = create(:user)
      @start_date = Date.today - 3.month
      @end_date = Date.today
    end

    it "builds transactions" do
      expect(@user.transactions.count).to eq 0
      retries = 0
      begin
        PlaidLoginItemCreator.call(@access_token, @user)
      rescue Plaid::ApiError => e
        if retries <= 3
          retries += 1
          sleep 3 ** retries
        end
        retry
      end
      expect(@user.transactions.count).to be > 0
    end

    after(:all) do
      Category.delete_all
    end
  end
end
