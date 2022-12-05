class PlaidTransactionsSyncProcessor < ApplicationService
  def initialize(access_token)
    @client = PlaidClientCreator.call
    @access_token = access_token
    @login_item = LoginItem.find_by(plaid_access_token: @access_token)
    @user_id = @login_item.user_id
    @company_id = @login_item.user.company_id
    @initial_cursor = @login_item.plaid_cursor
    @latest_cursor = nil
  end

  def call
    if @login_item.expired?
      Rails.logger.warn("[PlaidTransactionsSyncProcessor] Unable to sync transactions for expired login item with ID=#{@login_item.id}")
      return
    end
    plaid_transactions_response = fetch_transactions
    created_transactions = plaid_transactions_response.created_transactions
    modified_transactions = plaid_transactions_response.modified_transactions
    removed_transactions = plaid_transactions_response.removed_transactions
    Rails.logger.info("[PlaidTransactionsSyncProcessor] Created transactions count: #{created_transactions.count}")
    Rails.logger.info("[PlaidTransactionsSyncProcessor] Modified transactions count: #{modified_transactions.count}")
    Rails.logger.info("[PlaidTransactionsSyncProcessor] Created transaction count: #{removed_transactions.count}")
    transactions_to_be_upserted = created_transactions.concat(modified_transactions)
    if transactions_to_be_upserted.count > 0
      upserted_transaction_ids = create_or_update_transactions(transactions_to_be_upserted)
      DuplicateTransactionsProcessor.call(upserted_transaction_ids)
      NotificationsCreatorJob.perform_later(upserted_transaction_ids)
    end
    if removed_transactions.count > 0
      delete_transactions(removed_transactions)
    end
    @login_item.update(plaid_cursor: plaid_transactions_response.cursor)
    StatsCreatorJob.perform_later(@company_id)
  end

  private

  def fetch_transactions
    Rails.logger.info("[PlaidTransactionsSyncProcessor] Syncing transactions for login item with ID=#{@login_item&.id}")
    has_more_transactions = true
    created_transactions_json = []
    updated_transactions_json = []
    removed_transactions_json = []
    begin
      while has_more_transactions
        response = @client.transactions_sync(create_sync_request)
        created_transactions_json += response.added
        updated_transactions_json += response.modified
        removed_transactions_json += response.removed
        has_more_transactions = response.has_more
        @latest_cursor = response.next_cursor
      end
    rescue Plaid::ApiError => e
      Rails.logger.error("[PlaidTransactionsSyncProcessor] Unable to sync transactions for login item with ID=#{@login_item&.id}")
      Rails.logger.error(e.response_body)
      if item_expired?(e)
        Rails.logger.info("[PlaidTransactionsSyncProcessor] Expiring login item with ID=#{@login_item&.id}.")
        @login_item&.expire
      end
    rescue => e
      Rails.logger.error("[PlaidTransactionsSyncProcessor] Unable to add transactions for login item with ID=#{@login_item&.id}")
      Rails.logger.error(e)
    ensure
      return OpenStruct.new(
        created_transactions: created_transactions_json,
        modified_transactions: updated_transactions_json,
        removed_transactions: removed_transactions_json,
        cursor: @latest_cursor,
      )
    end
  end

  DEFAULT_COUNT = 500
  def create_sync_request
    request = Plaid::TransactionsSyncRequest.new({
      access_token: @access_token,
      cursor: @cursor,
      count: DEFAULT_COUNT,
      options: {
        include_personal_finance_category: true,
      }
    })
  end

  def create_or_update_transactions(transactions_list)
    upsert_list = []
    transactions_list.each do |transaction_json|
      begin
        bank_account = BankAccount.find_by!(plaid_account_id: transaction_json.account_id)
        category = Category.find_by!(plaid_category_id: transaction_json.category_id)
        category_id = category&.id
        essential = category.essential?
        transaction = Transaction.find_by_plaid_transaction_id(transaction_json.transaction_id)
        if transaction
          custom_description = transaction.custom_description
          created_at = transaction.created_at
          attributes = build_transaction_attributes(transaction_json, custom_description, bank_account.id, category_id, essential, created_at)
          upsert_list << attributes
        else
          custom_description = transaction_json.name
          created_at = Time.zone.now.utc
          attributes = build_transaction_attributes(transaction_json, custom_description, bank_account.id, category_id, essential, created_at)
          upsert_list << attributes
        end
      rescue => e
        Rails.logger.error("[PlaidTransactionsSyncProcessor] Unable to process transaction with payload: #{transaction_json}, exception - #{e}")
        Rails.logger.error(e.backtrace.join("\n"))
        TransactionError.create(
          user_id: @user_id,
          transaction_json: transaction_json,
          error_message: e.full_message,
          error_type: e.class.name,
        )
        next
      end
    end
    result = Transaction.upsert_all(upsert_list.compact, unique_by: [:plaid_transaction_id])
    Rails.logger.info("[PlaidTransactionsSyncProcessor] Total transactions saved to DB=#{result.length}")
    upserted_ids = result.map {|result| result["id"]}
    upserted_ids
  end

  def delete_transactions(transactions_list)
    removed_transactions = transactions_list.map { |transaction_json| transaction_json.transaction_id }
    Rails.logger.info("[PlaidTransactionsSyncProcessor] Total transactions deleted from DB=#{removed_transactions.length}")
    Transaction.destroy_by(plaid_transaction_id: removed_transactions)
  end

  def build_transaction_attributes(transaction_json, custom_description, bank_account_id, category_id, essential, created_at)
    {
      plaid_transaction_id: transaction_json.transaction_id,
      user_id: @user_id,
      amount: transaction_json.amount,
      currency_code: transaction_json.iso_currency_code,
      occured_at: transaction_json.date,
      authorized_at: transaction_json.authorized_date,
      location_json: transaction_json.location,
      description: transaction_json.name,
      custom_description: custom_description,
      transaction_type: transaction_json.transaction_type,
      payment_meta_json: transaction_json.payment_meta,
      payment_channel: transaction_json.payment_channel,
      pending: transaction_json.pending,
      plaid_pending_transaction_id: transaction_json.pending_transaction_id,
      transaction_code: transaction_json.transaction_code,
      bank_account_id: bank_account_id,
      category_id: category_id,
      created_at: created_at,
      updated_at: Time.zone.now.utc,
      merchant_name:transaction_json.merchant_name,
      essential: essential,
    }
  end
end