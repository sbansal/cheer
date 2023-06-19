module ApplicationHelper
  include Pagy::Frontend

  def active_menu_item(nav_item)
    case nav_item
    when "home"
      "active " if (controller_name == "dashboard" && action_name == "index")
    when "cashflow"
      "active " if (controller_name == "dashboard" && action_name == "cashflow")
    when "export"
      "active " if (controller_name == "dashboard" && action_name == "export")
    when "income_expense"
      "active " if (controller_name == "dashboard" && action_name == "income_expense")
    when "transactions"
      "active " if (controller_name == "transactions")
    when "bank_accounts"
      "active " if (controller_name == "bank_accounts")
    when "login_items"
      "active " if (controller_name == "login_items")
    when "account_settings"
      "active " if (controller_name == "companies" && action_name == "settings")
    when "subscriptions"
      "active " if (controller_name == "subscriptions")
    when "notifications"
      "active " if (controller_name == "notifications")
    when "privatefi"
      "active " if (controller_name == "chats")
    when "reports"
      "active " if (controller_name == "reports")  
    else
      ""
    end
  end

  def title(page_title)
    content_for(:title) { page_title }
  end

  def signed_number_to_currency(amount)
    css_class = amount > 0 ? "debit" : "credit"
    tag.div(class: css_class) do
      if amount < 0
        "+" + number_to_currency(amount.abs)
      else
        number_to_currency(amount.abs)
      end
    end
  end

  def formatted_date(some_date)
    if Date.today.year == some_date.year
      some_date.strftime('%b %-d')
    else
      some_date.strftime('%b %-d, %Y')
    end
  end
end
