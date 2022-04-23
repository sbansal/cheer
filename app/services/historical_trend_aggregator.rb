class HistoricalTrendAggregator < ApplicationService
  def initialize(time_series_data_hash)
    @time_series_data = time_series_data_hash
  end

  def call
    if @time_series_data.keys.length > 31
      @time_series_data.group_by { |k, v| k.beginning_of_month }.transform_values { |a| a.sum(&:last) }
    else
      @time_series_data
    end
  end

end