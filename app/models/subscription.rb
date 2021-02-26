class Subscription < ApplicationRecord
  belongs_to :last_transaction, class_name: 'Transaction', foreign_key: 'last_transaction_id'
  belongs_to :bank_account
  belongs_to :user

  POSSIBLE_DAILY_FREQUENCY = [1]
  POSSIBLE_WEEKLY_FREQUENCY = [7]
  POSSIBLE_MONTHLY_FREQUENCY = (28..33).to_a
  POSSIBLE_QUARTERLY_FREQUENCY = (86..95).to_a
  POSSIBLE_YEARLY_FREQUENCY = (360..370).to_a

  DAILY = 'daily'
  WEEKLY = 'weekly'
  MONTHLY = 'monthly'
  QUARTERLY = 'quarterly'
  ANNUAL = 'annual'

  def with_frequency(days_array)
    if dataset_within_frequency?(days_array, POSSIBLE_DAILY_FREQUENCY)
      self.frequency = DAILY
    elsif dataset_within_frequency?(days_array, POSSIBLE_WEEKLY_FREQUENCY)
      self.frequency = WEEKLY
    elsif dataset_within_frequency?(days_array, POSSIBLE_MONTHLY_FREQUENCY)
      self.frequency = MONTHLY
    elsif dataset_within_frequency?(days_array, POSSIBLE_QUARTERLY_FREQUENCY)
      self.frequency = QUARTERLY
    elsif dataset_within_frequency?(days_array, POSSIBLE_YEARLY_FREQUENCY)
      self.frequency = ANNUAL
    end
    self
  end

  def all_transactions
    last_transaction.related_transactions.where(amount: last_transaction.amount).order('occured_at desc')
  end

  def update_state
    last_transaction_date = last_transaction.occured_at
    if frequency == DAILY
      self.active = last_transaction_date.after?(1.day.ago)
    elsif frequency == WEEKLY
      self.active = last_transaction_date.after?(1.week.ago)
    elsif frequency == MONTHLY
      self.active = last_transaction_date.after?(1.month.ago)
    elsif frequency == QUARTERLY
      self.active = last_transaction_date.after?(3.month.ago)
    elsif frequency == ANNUAL
      self.active = last_transaction_date.after?(1.year.ago)
    else
      self.active = false
    end
  end
  
  def state
    self.active? ? 'active' : 'inactive'
  end

  private

  def dataset_within_frequency?(days_array, range_array)
    return false if days_array.length < 1
    return false if (range_array == POSSIBLE_DAILY_FREQUENCY && days_array.length < 6)
    return false if (range_array == POSSIBLE_WEEKLY_FREQUENCY && days_array.length < 3)
    range = ((days_array - range_array).length.to_f / days_array.length.to_f * 100)
    # puts "range=#{range} for range_array=#{range_array}, and days_array=#{days_array}"
    range < 50
  end
end
