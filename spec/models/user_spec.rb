require 'rails_helper'

RSpec.describe User, type: :model do
  
  it 'has subscriptions' do
    user = create(:user)
    expect(user.subscriptions.count).to eq 0
  end
end
