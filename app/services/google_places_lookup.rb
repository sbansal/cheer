class GooglePlacesLookup < ApplicationService
  GOOGLE_PLACE_URL = 'https://maps.googleapis.com/maps/api/place/autocomplete/json?'

  def initialize(query)
    @query = query
  end

  def call
    google_api_key = Rails.application.credentials[:google][:places_api_key]
    url = "#{GOOGLE_PLACE_URL}key=#{google_api_key}&input=#{@query}"
    response = Faraday.get(url)
    JSON.parse(response.body)
  end
end