class Trend
  attr_reader :last_change, :last_change_percentage, :time_period, :direction
  def initialize(current_value, prev_value, time_period="")
    @last_change = current_value - prev_value
    @direction = current_value >= prev_value ? 'up' : 'down'
    @last_change_percentage = (@last_change/prev_value)*100
    @time_period = time_period
  end

  def to_h
    {
      :last_change.to_s => @last_change,
      :last_change_percentage.to_s => @last_change_percentage,
      :direction.to_s => @direction,
    }
  end
end
