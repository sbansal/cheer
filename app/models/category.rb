class Category < ApplicationRecord
  has_many :transactions
  INTERNAL_ACCOUNT_TRANSFER = 'Internal Account Transfer'

  def category_list
    hierarchy.join(', ')
  end

  def internal_account_transfer?
    hierarchy.include?(INTERNAL_ACCOUNT_TRANSFER)
  end

  def self.find_all_for_category(category_name)
    where("hierarchy @> ?", '["' + "#{category_name}" + '"]')
  end
  
  def root_name
    hierarchy.first
  end
end
