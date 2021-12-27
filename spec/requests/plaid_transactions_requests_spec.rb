require 'rails_helper'
require 'plaid'

RSpec.describe "PlaidTransactionsRequests", type: :request do
  describe "GET Plaid transactions" do
    before(:all) do
      setup_categories
      @access_token = create_sandbox_link_and_fetch_access_token
      @user = create(:user)
      @start_date = Date.today - 3.month
      @end_date = Date.today
    end

    it "returns transactions" do
      expect {
        setup_login_item
      }.to change { @user.transactions.count }.by(16)
    end

    after(:all) do
      Category.delete_all
    end
  end

  private

  def create_sandbox_link_and_fetch_access_token
    request = Plaid::SandboxPublicTokenCreateRequest.new(
      {
        institution_id: 'ins_109508',
        initial_products: ["transactions"]
      }
    )
    client = PlaidClientCreator.call
    response = client.sandbox_public_token_create(request)
    publicToken = response.public_token
    item_public_token_exchange_request = Plaid::ItemPublicTokenExchangeRequest.new(
      {
        public_token: publicToken
      }
    )
    response = client.item_public_token_exchange(item_public_token_exchange_request)
    access_token = response.access_token
  end

  def setup_categories
    @client = PlaidClientCreator.call
    response = @client.categories_get({})
    @categories = response.categories
    @categories.each do |category|
      c = Category.find_or_initialize_by(plaid_category_id: category.category_id)
      c.update(
        group: category.group,
        hierarchy: category.hierarchy,
        rank: category.hierarchy.count,
      )
    end
  end

  def setup_login_item
    login_item = PlaidLoginItemCreator.call(@access_token, @user)
  end
end
