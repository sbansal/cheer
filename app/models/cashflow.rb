class Cashflow
  attr_reader :start_date, :end_date
  attr_reader :total_money_in, :total_money_out, :total_money_saved
  attr_reader :prev_total_money_in, :prev_total_money_out, :prev_total_money_saved

  def initialize(start_date, end_date, transactions)
    @start_date = start_date
    @end_date = end_date
    diff = end_date - start_date
    current_transactions = transactions.occured_between(start_date, end_date)
    @total_money_in, @total_money_out, @total_money_saved = build_cashflow(current_transactions)
    prev_transactions = transactions.occured_between(start_date - diff, end_date - diff)
    Rails.logger.info "Current transactions count = #{transactions.count} for #{start_date} to #{end_date}"
    Rails.logger.info "Prev transactions count = #{prev_transactions.count} for #{start_date - diff} to #{end_date - diff}"
    @prev_total_money_in, @prev_total_money_out, @prev_total_money_saved = build_cashflow(prev_transactions)
  end
  
  def delta
    {
     delta_money_in: compute_value(total_money_in, prev_total_money_in),
     delta_money_out: compute_value(total_money_out, prev_total_money_out),
     delta_money_saved: compute_value(total_money_saved, prev_total_money_saved),
    }
  end
  
  def time_period
    if (start_date.month == end_date.month) && (start_date.year == end_date.year) 
      "#{start_date.strftime('%b %Y')}"
    else
      "#{start_date.strftime('%b %-d, %Y')} - #{end_date.strftime('%b %-d, %Y')}"
    end
  end
  
  private
  
  def build_cashflow(transactions)
    total_money_out = 0
    total_money_in = 0
    transactions.each do |tx|
      if tx.charge?
        total_money_out += (tx.amount || 0)
      else
        total_money_in += (tx.amount || 0)
      end
    end
    total_money_saved = (total_money_in.abs - total_money_out.abs)
    return total_money_in, total_money_out, total_money_saved
  end
  
  def compute_value(current_value, prev_value)
    value = '-'
    percentage = '-'
    if prev_value
      diff = current_value.abs - prev_value.abs
      
      percentage = prev_value == 0 ? 'N/A' : 100 * (diff/prev_value.abs)
    end
    {value: diff, percentage: percentage}
  end
end