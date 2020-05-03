class Category < ApplicationRecord
  has_many :transactions
  INTERNAL_ACCOUNT_TRANSFER = 'Internal Account Transfer'

  def category_list
    hierarchy.join(', ')
  end

  def charge?
    !hierarchy.include?(INTERNAL_ACCOUNT_TRANSFER)
  end

  def self.find_all_for_category(category_name)
    where("hierarchy @> ?", '["' + "#{category_name}" + '"]')
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
end
