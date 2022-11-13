require 'rails_helper'

RSpec.describe NotificationsCreator do
  before(:all) do
    @user = create(:user)
    @transaction_ids = build_transactions
  end

  it 'creates duplicate transaction notification' do
  end

  it 'creates notifications' do
    expect {
      NotificationsCreator.call(@transaction_ids)
    }.to change { @user.notifications.count }.by(1)
  end

  private

  def build_transactions
    create(:transaction, occured_at: Date.today, amount: 100, user: @user)
    create(:transaction, occured_at: Date.today, amount: 100, user: @user)
    create(:transaction, occured_at: Date.today, amount: -100, user: @user)
    create(:transaction, occured_at: Date.today, amount: -100, user: @user)
    @user.transactions.map(&:id)
  end

end
