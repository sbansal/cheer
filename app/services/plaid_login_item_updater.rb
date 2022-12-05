class PlaidLoginItemUpdater < ApplicationService
  def initialize(login_item_id, fetch_transactions=true)
    @login_item = LoginItem.find(login_item_id)
    @client = PlaidClientCreator.call
    @fetch_transactions = fetch_transactions
  end

  def call
    begin
      update_login_item
      create_or_update_accounts
      if @fetch_transactions
        puts "fetch #{@login_item.id}"
        @login_item.fetch_transactions
      end
    rescue Plaid::ApiError => e
      Rails.logger.error("[PlaidLoginItemUpdater] Unable to update login item with ID=#{@login_item&.id}")
      Rails.logger.error(e.response_body)
      if item_expired?(e)
        Rails.logger.info("[PlaidLoginItemUpdater] Expiring login item with ID=#{@login_item&.id}.")
        @login_item&.expire
      end
    rescue Exception => e
      Rails.logger.error("[PlaidLoginItemUpdater] Unable to update login item with ID=#{@login_item&.id}")
      Rails.logger.error(e)
    end
  end

  private

  def update_login_item
    response = fetch_login_item_data
    status_json = response.status
    login_item_json = response.item
    @login_item.update(
      consent_expires_at: login_item_json&.consent_expiration_time,
      error_json: login_item_json&.error,
      last_successful_transaction_update_at: status_json&.transactions&.last_successful_update,
      last_failed_transaction_update_at: status_json&.transactions&.last_failed_update,
      last_webhook_sent_at: status_json&.last_webhook&.sent_at,
      last_webhook_code_sent: status_json&.last_webhook&.code_sent,
    )
  end

  def fetch_login_item_data
    @client.item_get(Plaid::ItemGetRequest.new({ access_token: @login_item.plaid_access_token }))
  end

  def fetch_accounts_data
    request = Plaid::AccountsGetRequest.new({ access_token: @login_item.plaid_access_token })
    accounts_response = @client.accounts_get(request)
    accounts_response.accounts
  end

  def create_or_update_accounts
    accounts_json_array = fetch_accounts_data
    BankAccount.create_accounts_from_json(accounts_json_array, @login_item.id, @login_item.user_id, @login_item.institution_id)
    BankAccount.update_balances(accounts_json_array)
    check_for_inactive_accounts(accounts_json_array)
  end

  def check_for_inactive_accounts(accounts_json_array)
    active_plaid_account_ids = accounts_json_array.map { |account_json| account_json.account_id }
    @login_item.bank_accounts.map(&:plaid_account_id).each do |account_id|
      unless active_plaid_account_ids.include?(account_id)
        BankAccount.find_by(plaid_account_id: account_id).update(archived: true)
      end
    end
  end
end
