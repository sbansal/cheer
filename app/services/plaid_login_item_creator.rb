class PlaidLoginItemCreator < ApplicationService
  def initialize(access_token, user)
    @client = PlaidClientCreator.call
    @access_token = access_token
    @user = user
  end

  def call
    login_item = create_login_item
    bank_accounts = create_accounts(login_item)
    add_transactions_for_accounts(bank_accounts)
  end

  private

  def create_login_item
    login_item_response = @client.item.get(@access_token)
    login_item_json = login_item_response[:item]
    status_json = login_item_response[:status]
    institution = create_institution(login_item_json[:institution_id])
    # create login item
    LoginItem.create_from_json(login_item_json, status_json, institution.id, @access_token, @user.id)
  end

  def create_institution(institution_id)
    institution = Institution.find_by_plaid_institution_id(institution_id)
    unless institution.present?
      institution_response = @client.institutions.get_by_id(institution_id, options: { include_optional_metadata: true })
      institution = Institution.create_from_json(institution_response[:institution])
    end
    institution
  end

  def create_accounts(login_item)
    accounts_response = @client.accounts.get(@access_token)
    accounts_array_json = accounts_response[:accounts]
    BankAccount.create_accounts_from_json(accounts_array_json, login_item.id, @user.id)
  end

  def add_transactions_for_accounts(bank_accounts)
    transactions_response = @client.transactions.get(
      @access_token,
      6.months.ago.to_date.iso8601,
      Date.today.iso8601
    )
    transactions_json_array = transactions_response[:transactions]
    Rails.logger.info "Total transactions that need to be fetched - #{transactions_response[:total_transactions]}"
    while transactions_json_array.length < transactions_response[:total_transactions]
      transactions_response = @client.transactions.get(
        @access_token,
        6.months.ago.to_date.iso8601,
        Date.today.iso8601
      )
      transactions_json_array << transactions_response[:transactions]
    end
    Transaction.create_transactions_from_json(transactions_json_array, @user.id)
  end
end