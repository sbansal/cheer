class Institution < ApplicationRecord
  has_many :login_items
  
  def self.create_from_json(institution_json)
    create(
      plaid_institution_id: institution_json.institution_id,
      name: institution_json.name,
      logo: institution_json.logo,
      url: institution_json.url,
    )
  end
end
