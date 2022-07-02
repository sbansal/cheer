require 'rails_helper'

RSpec.describe "Billings", type: :request do
  describe "GET /new" do
    it 'should redirect user to a new billing path if there is no active subscription' do
      @user = FactoryBot.create(:user)
      @user.confirm
      sign_in @user
      get root_url
      expect(response.status).to eq(302)
      expect(response.header['Location']).to eq('http://app.example.com/billing/new')
    end

    it 'should redirect user to the root page if there is a active subscription' do
      @user = FactoryBot.create(:user)
      @user.confirm
      allow(@user.company).to receive(:has_active_subscription?).and_return(true)
      sign_in @user
      get root_url
      expect(response).to be_successful
    end
  end
end
