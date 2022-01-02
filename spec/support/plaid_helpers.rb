module PlaidHelpers
  def create_plaid_sandbox_link_and_fetch_access_token
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
  
  def setup_plaid_categories
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
end