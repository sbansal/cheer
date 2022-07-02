require 'rails_helper'
require 'stripe_mock'

RSpec.describe StripeWebhookEventProcessor do
  before do
    ActiveJob::Base.queue_adapter = :test
    stub_credential(stripe: { api_key: '123'} )
  end

  after(:each) do
    ActiveJob::Base.queue_adapter.enqueued_jobs.clear
  end

  let(:request) {
    double("request", body: OpenStruct.new({ read: 'body' }), env: {'HTTP_STRIPE_SIGNATURE': 'HTTP_STRIPE_SIGNATURE'})
  }

  describe 'customer.created event' do
    it 'processes event and updates user' do
      event = create_mock_stripe_event('customer.created')
      customer = event.data.object
      user = create(:user, email: customer.email)
      expect(user.stripe_customer_id).to be_nil
      StripeWebhookEventProcessor.call(request)
      expect(User.find(user.id).stripe_customer_id).to eq customer.id
    end

    it 'processes event and does not update user' do
      event = create_mock_stripe_event('customer.created')
      customer = event.data.object
      user = create(:user)
      StripeWebhookEventProcessor.call(request)
      expect(User.find(user.id).stripe_customer_id).to be_nil
    end
  end

  describe 'customer.deleted event' do
    it 'processes event and updates user' do
      event = create_mock_stripe_event('customer.deleted')
      customer = event.data.object
      user = create(:user, email: customer.email, stripe_customer_id: customer.id)
      StripeWebhookEventProcessor.call(request)
      expect(User.find(user.id).stripe_customer_id).to be_nil
    end

    it 'processes event and does not update user' do
      event = create_mock_stripe_event('customer.created')
      customer = event.data.object
      user = create(:user, email: customer.email, stripe_customer_id: customer.id)
      StripeWebhookEventProcessor.call(request)
      expect(User.find(user.id).stripe_customer_id).to eq customer.id
    end
  end

  describe 'customer.subscription.created' do
    it 'processes event and updates user' do
      event = create_mock_stripe_event('customer.subscription.created')
      subscription = event.data.object
      user = create(:user, stripe_customer_id: subscription.customer)
      expect(user.company.stripe_subscription_id).to be_nil
      StripeWebhookEventProcessor.call(request)
      expect(User.find(user.id).company.stripe_subscription_id).to eq subscription.id
      expect(User.find(user.id).company.stripe_subscription_id).to eq subscription.id
      expect(User.find(user.id).company.stripe_pricing_plan).to eq subscription.items.data.first.price.id
      expect(User.find(user.id).company.last_payment_processed_at).to eq Time.at(subscription.current_period_start)
      expect(User.find(user.id).company.next_payment_at).to eq Time.at(subscription.current_period_end)
      expect(User.find(user.id).company.subscription_status).to eq subscription.status
      expect {
        StripeWebhookEventProcessor.call(request)
      }.to have_enqueued_job(
        ActionMailer::MailDeliveryJob
      ).with('GenericMailer', 'customer_subscription_created_notification', 'deliver_now', {args: [user.id]})
    end

    it 'processes event and does not update user' do
      event = create_mock_stripe_event('customer.subscription.created')
      subscription = event.data.object
      user = create(:user)
      StripeWebhookEventProcessor.call(request)
      expect(User.find(user.id).company.stripe_subscription_id).to be_nil
      expect(User.find(user.id).company.stripe_subscription_id).to be_nil
      expect(User.find(user.id).company.stripe_pricing_plan).to be_nil
      expect(User.find(user.id).company.last_payment_processed_at).to be_nil
      expect(User.find(user.id).company.next_payment_at).to be_nil
      expect(User.find(user.id).company.subscription_status).to be_nil
    end
  end

  describe 'customer.subscription.updated' do
    it 'processes event and updates user' do
      event = create_mock_stripe_event('customer.subscription.updated')
      subscription = event.data.object
      user = create(:user, stripe_customer_id: subscription.customer)
      expect(user.company.stripe_subscription_id).to be_nil
      StripeWebhookEventProcessor.call(request)
      expect(User.find(user.id).company.stripe_subscription_id).to eq subscription.id
      expect(User.find(user.id).company.stripe_subscription_id).to eq subscription.id
      expect(User.find(user.id).company.stripe_pricing_plan).to eq subscription.items.data.first.price.id
      expect(User.find(user.id).company.last_payment_processed_at).to eq Time.at(subscription.current_period_start)
      expect(User.find(user.id).company.next_payment_at).to eq Time.at(subscription.current_period_end)
      expect(User.find(user.id).company.subscription_status).to eq subscription.status
    end

    it 'processes event and does not update user' do
      event = create_mock_stripe_event('customer.subscription.updated')
      subscription = event.data.object
      user = create(:user)
      StripeWebhookEventProcessor.call(request)
      expect(User.find(user.id).company.stripe_subscription_id).to be_nil
    end
  end

  describe 'customer.subscription.deleted' do
    it 'processes event and updates user' do
      event = create_mock_stripe_event('customer.subscription.deleted')
      subscription = event.data.object
      user = create(:user, stripe_customer_id: subscription.customer)
      expect(user.company.stripe_subscription_id).to be_nil
      StripeWebhookEventProcessor.call(request)
      expect(User.find(user.id).company.stripe_subscription_id).to eq subscription.id
      expect(User.find(user.id).company.stripe_pricing_plan).to eq subscription.items.data.first.price.id
      expect(User.find(user.id).company.last_payment_processed_at).to eq Time.at(subscription.current_period_start)
      expect(User.find(user.id).company.next_payment_at).to eq Time.at(subscription.current_period_end)
      expect(User.find(user.id).company.subscription_status).to eq subscription.status
      expect {
        StripeWebhookEventProcessor.call(request)
      }.to have_enqueued_job(
        ActionMailer::MailDeliveryJob
      ).with('GenericMailer', 'customer_subscription_deleted_notification', 'deliver_now', {args: [subscription.id, user.id]})
    end

    it 'processes event and does not update user' do
      event = create_mock_stripe_event('customer.subscription.deleted')
      subscription = event.data.object
      user = create(:user)
      StripeWebhookEventProcessor.call(request)
      expect(User.find(user.id).company.stripe_subscription_id).to be_nil
      expect(User.find(user.id).company.stripe_pricing_plan).to be_nil
      expect(User.find(user.id).company.last_payment_processed_at).to be_nil
      expect(User.find(user.id).company.next_payment_at).to be_nil
      expect(User.find(user.id).company.subscription_status).to be_nil
      expect {
        StripeWebhookEventProcessor.call(request)
      }.not_to have_enqueued_job(
        ActionMailer::MailDeliveryJob
      ).with('GenericMailer', 'customer_subscription_deleted_notification', 'deliver_now', {args: [subscription.id, user.id]})
    end
  end

  private

  def create_mock_stripe_event(event_type)
    StripeMock.start
    event = StripeMock.mock_webhook_event(event_type)
    allow(Stripe::Webhook).to receive(:construct_event) { event }
    StripeMock.stop
    event
  end

end
