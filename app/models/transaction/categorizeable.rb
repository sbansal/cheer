module Transaction::Categorizeable
  extend ActiveSupport::Concern

  class_methods do
    def by_category(category)
      transactions = where(category: category)
      @categorized_transactions ||= Transaction::CategorizedTransaction.new(category, transactions)
    end
  end

end