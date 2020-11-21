namespace :institutions do
  desc "Fetches all the institutions from plaid and caches is locally"
  task pull_from_plaid: :environment do
    client = PlaidClientCreator.call
    country_codes = Rails.application.credentials[:plaid][:country_codes]
    institutions_response = client.institutions.get(count: 500, offset: 0, country_codes: country_codes)
    institutions = institutions_response['institutions']
    total = institutions_response['total']
    while institutions.length < total
      puts "Fetched institutions #{institutions.length}/#{total}"
      institutions_response = client.institutions.get(
        count: 500,
        offset: institutions.length,
        country_codes: country_codes,
      )
      institutions += institutions_response['institutions']
    end
    puts "Fetched institutions #{institutions.length}/#{total}"
    create_institutions_array = institutions.flatten.filter_map do |institution_json|
      if Institution.find_by_plaid_institution_id(institution_json['institution_id']).nil?
        {
          plaid_institution_id: institution_json.institution_id,
          name: institution_json.name,
          logo: institution_json.logo,
          url: institution_json.url,
          created_at: Time.zone.now.utc,
          updated_at: Time.zone.now.utc,
        }
      end
    end

    puts "Creating #{create_institutions_array.count} institutions."

    insertions = []
    create_institutions_array.each_slice(1000) do |slice|
      insertions += Institution.insert_all(slice)
    end

    puts "Inserted #{insertions.flatten.count} institutions."
  end
end
