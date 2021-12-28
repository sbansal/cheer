require 'rails_helper'

RSpec.describe "PlaidControllers", type: :request do
  before(:each) do
    @user = FactoryBot.create(:user)
    @user.confirm
    sign_in @user
  end

  describe "POST /generate_access_token" do
    it 'should return a successful respone' do
      params = { :public_token => 'public_token' }
      allow(PlaidPublicTokenExchanger).to receive(:call) { create_plaid_sandbox_link_and_fetch_access_token }
      post plaid_generate_access_token_url(params)
      expect(response).to be_successful
      expect {
        post plaid_generate_access_token_url(params)
      }.to change(LoginItem, :count).by(1)
      expect(flash[:notice_header]).to eq 'New link created'
    end
  end

  describe "POST /update_link" do
    it 'should return a successful respone' do
      login_item = create(:login_item, user: @user)
      params = { :link_token => login_item.link_token }
      post plaid_update_link_url(params)
      expect(response).to be_successful
      expect(flash[:notice_header]).to eq 'Link updated'
      expect(flash[:notice]).to eq 'Your link to Chase has been renewed successfully.'
    end
  end

  describe "POST /create_link_token" do
    it 'should return a successful respone' do
      params = { :format => 'json' }
      post plaid_create_link_token_url(params)
      expect(response).to be_successful
      expect(response.body['link_token']).not_to be_nil
    end
  end
end
