require 'rails_helper'

RSpec.describe NotificationsCreator do
  before(:all) do
    @user = create(:user)
    build_notification_templates
    @transaction_ids = build_transactions
  end

  it 'creates notifications' do
    expect {
      NotificationsCreator.call(@transaction_ids)
    }.to change { @user.notifications.count }.by(2)
  end

  it 'creates duplicate transaction notification' do
    tx = create(:transaction, occured_at: Date.today, amount: -100, user: @user, duplicate: true)
    expect {
      NotificationsCreator.call([tx.id])
    }.to change { @user.notifications.count }.by(1)
  end

  private

  def build_notification_templates
    NotificationTemplate.create([
      {
        title: 'When duplicate transactions are found.',
        frequency: 'daily',
      },
      {
        title: 'When refunds are issued.',
        frequency: 'daily',
      },
      {
        title: 'When a fee is charged to your account.',
        frequency: 'daily',
      },
      {
        title: 'When your salary is posted to your account.',
        frequency: 'daily',
      },
      {
        title: 'Weekly email summary of your Net Worth and Cashflow.',
        frequency: 'weekly',
      },
    ])
  end

  def build_transactions
    create(:transaction, occured_at: Date.today, amount: 100, user: @user)
    create(:transaction, occured_at: Date.today, amount: 100, user: @user)
    create(:transaction, occured_at: Date.today, amount: -100, user: @user)
    create(:transaction, occured_at: Date.today, amount: -100, user: @user, duplicate: true)
    @user.transactions.map(&:id)
  end

end
