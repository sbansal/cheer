class PersonalController < ApplicationController
  layout 'intro'
  def index
    @accounts = current_company.bank_accounts.where('plaid_account_id is not null').includes([:institution])
    @accounts_count = @accounts.count
  end

  def show
    @income_by_category = current_company.transactions.credits.group_by(&:category).map {
      |category, transactions| Transaction::CategorizedTransaction.new(category, transactions)
    }.sort_by { |item| item.total_spend }
    @expenses_by_category = current_company.transactions.debits.group_by(&:category).map {
      |category, transactions| Transaction::CategorizedTransaction.new(category, transactions)
    }.sort_by { |item| -item.total_spend }
  end
end
