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
        frequency: 'daily',
        template_type: NotificationTemplate::DUPLICATE_TEMPLATE_TYPE,
      },
      {
        template_type: NotificationTemplate::REFUNDS_TEMPLATE_TYPE,
        frequency: 'daily',
      },
      {
        template_type: NotificationTemplate::FEE_CHARGED_TEMPLATE_TYPE,
        frequency: 'daily',
      },
      {
        template_type: NotificationTemplate::SALARY_POSTED_TEMPLATE_TYPE,
        frequency: 'daily',
      },
      {
        template_type: NotificationTemplate::EMAIL_SUMMARY_TEMPLATE_TYPE,
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
