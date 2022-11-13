class NotificationsCreator < ApplicationService
  attr_reader :transaction_ids
  def initialize(transaction_ids)
    @transaction_ids = transaction_ids
  end

  def call
    @transaction_ids.each do |transaction_id|
      transaction = Transaction.find(transaction_id)
    end
  end

  private

  def create_duplicate_notification

  end
end