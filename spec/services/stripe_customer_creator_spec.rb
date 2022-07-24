require 'rails_helper'
require 'stripe_mock'

RSpec.describe StripeCustomerCreator do

  it 'should update the user with stripe customer id' do
    company = create(:company, created_at: 1.year.ago)
    user = create(:user, company: company)
    expect(user.stripe_customer_id).to be_nil
    stub_credential(stripe: { api_key: '123'} )
    StripeMock.start
    StripeCustomerCreator.call(user.id)
    StripeMock.stop
    expect(User.find(user.id).stripe_customer_id).not_to be_nil
  end

  private

  def stub_credential(**credentials)
    allow(Rails.application).to receive(:credentials).and_return(
      OpenStruct.new(**credentials)
    )
  end
end

