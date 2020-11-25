class SearchController < ApplicationController
  def address
    query = params['query']
    response, status = GooglePlacesLookup.call(query)
    logger.info("Status = #{status}, response=#{response}")
    @predictions = response['predictions']
    respond_to do |format|
      format.js
    end
  end
end
