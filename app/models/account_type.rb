class AccountType < ApplicationRecord

  def display_name
    name.humanize
  end

  def self.hierarchy
    AccountType.all.map { |at| [at['name'], at.subtype_array.map {|item| [item['name'], item['description'] ]}] }.to_h
  end

  def self.objectify
    JSON.parse(AccountType.all.to_json, object_class: OpenStruct)
  end

  def self.find_all_for_category(account_category)
    case account_category
    when "real_estate"
      where(name: 'real estate')
    when "liability"
      where(asset_category: false)
    else
      where("asset_category = :asset_category and name != :name", { asset_category: true, name: "real estate" })
    end
  end
end
