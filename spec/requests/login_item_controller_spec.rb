require 'rails_helper'

RSpec.describe "LoginItemControllers", type: :request do
  describe "DELETE destroy" do
    before(:each) do
      @user = FactoryBot.create(:user)
      @user.confirm
      sign_in @user
    end

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
end
