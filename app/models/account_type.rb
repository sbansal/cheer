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
end
