require 'rails_helper'

RSpec.describe "LoginItemControllers", type: :request do
  before(:each) do
    @user = FactoryBot.create(:user)
    @user.confirm
    sign_in @user
  end

  describe "GET index" do
    it 'should render a successful response' do
      login_item = create(:login_item, user: @user)
      get login_items_url
      expect(response).to be_successful
    end

    it 'should render a successful response with an expired login_item' do
      login_item = create(:login_item, user: @user, expired: true)
      allow(PlaidLinkTokenCreator).to receive(:call) { link_token_create_response }
      get login_items_url
      expect(response).to be_successful
    end

    it 'should render a successful response with an expired login_item for non-plaid item' do
      login_item = create(:login_item, user: @user, expired: true)
      get login_items_url
      expect(response).to be_successful
    end
  end

  describe "DELETE destroy" do

    it 'should delete the login items' do
      login_item = create(:login_item, user: @user)
      allow(PlaidLinkDeleter).to receive(:call) { true }
      expect {
        delete login_item_url(login_item)
      }.to change(LoginItem, :count).by(-1)
    end

    it 'should redirect to the login_items page' do
      login_item = create(:login_item, user: @user)
      allow(PlaidLinkDeleter).to receive(:call) { true }
      delete login_item_url(login_item)
      expect(response).to redirect_to(login_items_url)
    end
  end

  private

  def link_token_create_response
    {
      "link_token": "link-sandbox-af1a0311-da53-4636-b754-dd15cc058176",
      "expiration": "2020-03-27T12:56:34Z",
      "request_id": "XQVgFigpGHXkb0b"
    }
  end
end
