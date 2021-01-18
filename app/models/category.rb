class Category < ApplicationRecord
  has_many :transactions
  INTERNAL_ACCOUNT_TRANSFER = 'Internal Account Transfer'
  CC_PAYMENT_PLAID_ID = '16001000'
  INTERNAL_ACCOUNT_TRANSFER_PLAID_ID = '21001000'
  IGNORE_LIST = [INTERNAL_ACCOUNT_TRANSFER_PLAID_ID]
  CREDIT_IGNORE_LIST = [CC_PAYMENT_PLAID_ID]

  def category_list
    hierarchy.join(', ')
  end

  def charge?
    !hierarchy.include?(INTERNAL_ACCOUNT_TRANSFER)
  end

  def ignore_for_debit?
    IGNORE_LIST.include?(plaid_category_id)
  end

  def ignore_for_credit?
    IGNORE_LIST.include?(plaid_category_id) || CREDIT_IGNORE_LIST.include?(plaid_category_id)
  end

  def cc_payment?
    plaid_category_id == CC_PAYMENT_PLAID_ID
  end

  def root_name
    hierarchy.first
  end

  def secondary_names
    hierarchy.drop(1)
  end

  def category_list_item
    arrow = "\u2192"
    arrow = arrow.encode('utf-8')
    hierarchy.join(" #{arrow} ")
  end

  def primary_name
    hierarchy.last
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
    Category.where("hierarchy @> ? and rank = ?", self.hierarchy.to_s, self.rank + 1)
  end

  def self.root_menu_items
    Category.where(rank: 1).order('hierarchy asc').map { |item| {
      id: item.id, name: item.name, has_children: !item.sub_categories.empty?
    }}
  end
end
