class Subscription < ApplicationRecord
  belongs_to :last_transaction, class_name: 'Transaction', foreign_key: 'last_transaction_id'
  belongs_to :bank_account
  belongs_to :user

  POSSIBLE_DAILY_FREQUENCY = [1]
  POSSIBLE_WEEKLY_FREQUENCY = [7]
  POSSIBLE_MONTHLY_FREQUENCY = [29, 30, 31]
  POSSIBLE_QUARTERLY_FREQUENCY = [90, 91, 92]
  POSSIBLE_YEARLY_FREQUENCY = [365, 366]

  DAILY = 'daily'
  WEEKLY = 'weekly'
  MONTHLY = 'monthly'
  QUARTERLY = 'quarterly'
  ANNUAL = 'annual'

  def with_frequency(days_array)
    if days_array.eql? POSSIBLE_DAILY_FREQUENCY
      self.frequency = DAILY
    elsif days_array.eql? POSSIBLE_WEEKLY_FREQUENCY
      self.frequency = WEEKLY
    elsif (days_array - POSSIBLE_MONTHLY_FREQUENCY).empty?
      self.frequency = MONTHLY
    elsif (days_array - POSSIBLE_QUARTERLY_FREQUENCY).empty?
      self.frequency = QUARTERLY
    elsif (days_array - POSSIBLE_YEARLY_FREQUENCY).empty?
      self.frequency = ANNUAL
    else
      self.frequency = nil
    end
    self
  end

  def all_transactions
    bank_account.transactions.where(description: description, amount: last_transaction.amount).includes(:bank_account)
  end

  def active?
    last_transaction_date = last_transaction.occured_at
    if frequency == DAILY
      last_transaction_date.after?(1.day.ago)
    elsif frequency == MONTHLY
      last_transaction_date.after?(1.month.ago)
    elsif frequency == QUARTERLY
      last_transaction_date.after?(3.month.ago)
    elsif frequency == ANNUAL
      last_transaction_date.after?(1.year.ago)
    else
      false
    end
  end
end
