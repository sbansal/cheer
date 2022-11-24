module NotificationHelper
  def expanded_description(notification)
    transaction = notification.transaction_reference
    return "" unless transaction
    amount = transaction.amount.abs
    bank_account_name = transaction.bank_account.display_name
    case notification.description
    when Notification::DUPLICATE_DESCRIPTION
      "A duplicate transaction of #{number_to_currency(amount)} was found on #{bank_account_name}"
    when Notification::REFUNDS_DESCRIPTION
      "A credit of #{number_to_currency(amount)} was added to #{bank_account_name}"
    when Notification::SALARY_DESCRIPTION
      "You got paid. #{number_to_currency(amount)} was deposited to #{bank_account_name}"
    when Notification::FEE_CHARGED_DESCRIPTION
      "A fee of #{number_to_currency(amount)} was charged to #{bank_account_name}"
    end
  end
end