class Subscription < ApplicationRecord
  belongs_to :last_transaction, class_name: 'Transaction', foreign_key: 'last_transaction_id'
  belongs_to :bank_account

  POSSIBLE_DAILY_FREQUENCY = [1]
  POSSIBLE_WEEKLY_FREQUENCY = [7]
  POSSIBLE_MONTHLY_FREQUENCY = [29, 30, 31]
  POSSIBLE_QUARTERLY_FREQUENCY = [90, 91, 92]
  POSSIBLE_YEARLY_FREQUENCY = [365, 366]

  def with_frequency(days_array)
    if days_array.eql? POSSIBLE_DAILY_FREQUENCY
      self.frequency = 'daily'
    elsif days_array.eql? POSSIBLE_WEEKLY_FREQUENCY
      self.frequency = 'weekly'
    elsif (days_array - POSSIBLE_MONTHLY_FREQUENCY).empty?
      self.frequency = 'monthly'
    elsif (days_array - POSSIBLE_QUARTERLY_FREQUENCY).empty?
      self.frequency = 'quarterly'
    elsif (days_array - POSSIBLE_YEARLY_FREQUENCY).empty?
      self.frequency = 'yearly'
    else
      self.frequency = nil
    end
    self
  end
end
