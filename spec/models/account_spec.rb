require 'rails_helper'

RSpec.describe Account, type: :model do
  before(:all) do
    @account = create(:account_with_users)
  end

  it 'has users' do
    expect(@account.users.count).to be > 0
  end
end
