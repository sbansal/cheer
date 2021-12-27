namespace :categories do
  desc "Fetch the plaid categories and save in the DB"
  task update_from_plaid: :environment do
    @client = PlaidClientCreator.call
    response = @client.categories_get({})
    @categories = response.categories
    @categories.each do |category|
      c = Category.find_or_initialize_by(plaid_category_id: category.category_id)
      c.update(
        group: category.group,
        hierarchy: category.hierarchy,
        rank: category.hierarchy.count
      )
    end
  end

  task catergorize_transactions: :environment do
    Transaction.all.each do |transaction|
      transaction.update(category_id: Category.find_by_plaid_category_id(transaction.plaid_category_id)&.id)
    end
  end
end
