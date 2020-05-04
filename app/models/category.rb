class Category < ApplicationRecord
  has_many :transactions
  INTERNAL_ACCOUNT_TRANSFER = 'Internal Account Transfer'

  def category_list
    hierarchy.join(', ')
  end

  def charge?
    !hierarchy.include?(INTERNAL_ACCOUNT_TRANSFER)
  end

  def self.find_all_for_category(category_names)
    where("hierarchy @> ?", category_names.to_s)
  end
  
  def root_name
    hierarchy.first
  end
  
  def secondary_names
    hierarchy.drop(1)
  end
  
  def primary_name
    hierarchy.last
  end
  
  def descriptive_name
    hierarchy.reverse.join(' ')
  end
  
  def parent
    category_names = hierarchy.slice(0, hierarchy.length - 1)
    if category_names.empty?
      nil
    else
      Category.where("hierarchy = ?", category_names.to_s).first
    end
  end
  
  def children
    categories = Category.find_all_for_category(hierarchy.to_s)
    if categories.empty?
      []
    else
      categories.reject { |category| category.id == self.id }
    end
  end
end
