module ApplicationHelper
  def active_menu_item(nav_item)
    case nav_item
    when "home"
      "active " if (controller_name == "dashboard" && action_name == "index")
    when "cashflow"
      "active " if (controller_name == "dashboard" && action_name == "cashflow")
    when "income_expense"
      "active " if (controller_name == "dashboard" && action_name == "income_expense")
    when "transactions"
      "active " if (controller_name == "transactions" && action_name == "index")
    when "bank_accounts"
      "active " if (controller_name == "bank_accounts" && action_name == "index")
    when "login_items"
      "active " if (controller_name == "login_items" && action_name == "index")
    when "account_settings"
      "active " if (controller_name == "accounts" && action_name == "settings")
    when "subscriptions"
      "active " if (controller_name == "subscriptions")
    else
      ""
    end
  end
end
