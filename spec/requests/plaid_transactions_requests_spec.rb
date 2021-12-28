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
      expect {
        PlaidLoginItemCreator.call(@access_token, @user)
      }.to change { @user.transactions.count }.by(16)
    end

    after(:all) do
      Category.delete_all
    end
  end
end
