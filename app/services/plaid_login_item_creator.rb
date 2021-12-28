class PlaidLoginItemCreator < ApplicationService
  def initialize(access_token, user)
    @client = PlaidClientCreator.call
    @access_token = access_token
    @user = user
  end

  def call
    login_item = create_login_item
    login_item.activate
    login_item.register_webhook
    bank_accounts = create_accounts(login_item)
    PlaidTransactionsCreator.call(@access_token, @user, 3.months.ago.to_date.iso8601, Date.today.iso8601)
    login_item
  end

  private

  def create_login_item
    request = Plaid::ItemGetRequest.new({ access_token: @access_token })
    login_item_response = @client.item_get(request)
    login_item_json = login_item_response.item
    status_json = login_item_response.status
    institution = create_institution(login_item_json.institution_id)
    LoginItem.create_from_json(login_item_json, status_json, institution.id, @access_token, @user.id)
  end

  def create_institution(institution_id)
    institution = Institution.find_by_plaid_institution_id(institution_id)
    unless institution.present?
      request = Plaid::InstitutionsGetByIdRequest.new(
        {
          institution_id: institution_id,
          country_codes: Rails.application.credentials[:plaid][:country_codes],
          options: { include_optional_metadata: true }
        }
      )
      institution_response = @client.institutions_get_by_id(request)
      institution = Institution.create_from_json(institution_response.institution)
    end
    institution
  end

  def create_accounts(login_item)
    request = Plaid::AccountsGetRequest.new({ access_token: @access_token })
    accounts_response = @client.accounts_get(request)
    accounts_array_json = accounts_response.accounts
    BankAccount.create_accounts_from_json(accounts_array_json, login_item.id, @user.id, login_item.institution_id)
  end
end