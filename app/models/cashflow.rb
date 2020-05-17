class Cashflow
  attr_reader :total_money_in, :total_money_out, :total_money_saved
  attr_reader :prev_total_money_in, :prev_total_money_out, :prev_total_money_saved
  def initialize(transactions)
    build_cashflow(transactions)
  end
  
  def update_delta(prev_cashflow)
    @prev_total_money_in = prev_cashflow.total_money_in
    @prev_total_money_out = prev_cashflow.total_money_out
    @prev_total_money_saved = prev_cashflow.total_money_saved
  end
  
  def delta
    {
     delta_money_in: compute_value(total_money_in, prev_total_money_in),
     delta_money_out: compute_value(total_money_out, prev_total_money_out),
     delta_money_saved: compute_value(total_money_saved, prev_total_money_saved),
    }
  end
  
  def time_period
    "Current Month"
  end
  
  private
  
  def build_cashflow(transactions)
    @total_money_out = 0
    @total_money_in = 0
    transactions.each do |tx|
      if tx.charge?
        @total_money_out += (tx.amount || 0)
      else
        @total_money_in += (tx.amount || 0)
      end
    end
    @total_money_saved = (total_money_in.abs - total_money_out.abs)
  end
  
  def compute_value(current_value, prev_value)
    value = '-'
    percentage = '-'
    if prev_value
      diff = current_value.abs - prev_value.abs
      percentage = 100 * (diff/prev_value.abs)
    end
    {value: diff, percentage: percentage}
  end
end