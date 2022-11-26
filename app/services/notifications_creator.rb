class NotificationsCreator < ApplicationService
  attr_reader :transaction_ids
  def initialize(transaction_ids=[])
    @transaction_ids = transaction_ids
  end

  def call
    @transaction_ids.map do |transaction_id|
      transaction = Transaction.find(transaction_id)
      create_notifications(transaction)
    end
  end

  private

  def create_notifications(transaction)
    if transaction.duplicate?
      create_duplicate_transaction(transaction)
    else
      if transaction.refund?
        create_refund_notification(transaction)
      end
      if transaction.payroll?
        create_payroll_notification(transaction)
      end
      if transaction.fee_charged?
        create_fee_charged_notification(transaction)
      end
    end
  end

  def create_duplicate_transaction(transaction)
    Notification.create(
      user_id: transaction.user_id,
      notification_template_id: NotificationTemplate.find_duplicate_template.id,
      description: Notification::DUPLICATE_DESCRIPTION,
      reference_entity_gid: transaction.to_global_id.to_s,
    )
  end

  def create_refund_notification(transaction)
    Notification.create(
      user_id: transaction.user_id,
      notification_template_id: NotificationTemplate.find_refunds_template.id,
      description: Notification::REFUNDS_DESCRIPTION,
      reference_entity_gid: transaction.to_global_id.to_s,
    )
  end

  def create_payroll_notification(transaction)
    Notification.create(
      user_id: transaction.user_id,
      notification_template_id: NotificationTemplate.find_salary_posted_template.id,
      description: Notification::SALARY_DESCRIPTION,
      reference_entity_gid: transaction.to_global_id.to_s,
    )
  end

  def create_fee_charged_notification(transaction)
    Notification.create(
      user_id: transaction.user_id,
      notification_template_id: NotificationTemplate.find_fee_charged_template.id,
      description: Notification::FEE_CHARGED_DESCRIPTION,
      reference_entity_gid: transaction.to_global_id.to_s,
    )
  end
end