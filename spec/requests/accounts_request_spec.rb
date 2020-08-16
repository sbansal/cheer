require 'rails_helper'

RSpec.describe "Accounts", type: :request do

  describe "GET /settings" do
    it "returns http success" do
      get "/accounts/settings"
      expect(response).to have_http_status(:success)
    end
  end

end
