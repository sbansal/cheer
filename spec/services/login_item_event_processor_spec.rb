require 'rails_helper'

RSpec.describe LoginItemEventProcessor do
  before(:all) do
    @login_item = create(:login_item)
  end

  let(:metadata) {
    {
      new_webhook_url: 'http://webhook.dev',
      'consent_expiration_time' => '2019-10-12T07:20:50.52Z'
    }
  }
  it 'processes webhook update acknowledged event' do
    expect(LoginItem.find(@login_item.id).last_webhook_code_sent).to be_nil
    expect(LoginItem.find(@login_item.id).last_webhook_sent_at).to be_nil
    LoginItemEventProcessor.call(LoginItemEventProcessor::WEBHOOK_UPDATE_ACKNOWLEDGED_CODE, @login_item.plaid_item_id, metadata)
    expect(LoginItem.find(@login_item.id).last_webhook_code_sent).to eq(LoginItemEventProcessor::WEBHOOK_UPDATE_ACKNOWLEDGED_CODE)
    expect(LoginItem.find(@login_item.id).last_webhook_sent_at).not_to be_nil
  end

  it 'processes pending expiration event' do
    expect(LoginItem.find(@login_item.id).last_webhook_code_sent).to be_nil
    expect(LoginItem.find(@login_item.id).last_webhook_sent_at).to be_nil
    expect(LoginItem.find(@login_item.id).consent_expires_at).to be_nil
    LoginItemEventProcessor.call(LoginItemEventProcessor::PENDING_EXPIRATION_CODE, @login_item.plaid_item_id, metadata)
    expect(LoginItem.find(@login_item.id).last_webhook_code_sent).to eq(LoginItemEventProcessor::PENDING_EXPIRATION_CODE)
    expect(LoginItem.find(@login_item.id).last_webhook_sent_at).not_to be_nil
    expect(LoginItem.find(@login_item.id).consent_expires_at).not_to be_nil
  end

  it 'processes error event' do
    expect(LoginItem.find(@login_item.id).last_webhook_code_sent).to be_nil
    expect(LoginItem.find(@login_item.id).last_webhook_sent_at).to be_nil
    expect(LoginItem.find(@login_item.id).expired).to eq(false)
    expect(LoginItem.find(@login_item.id).expired_at).to be_nil
    LoginItemEventProcessor.call(LoginItemEventProcessor::ERROR_CODE, @login_item.plaid_item_id, metadata)
    expect(LoginItem.find(@login_item.id).last_webhook_code_sent).to eq(LoginItemEventProcessor::ERROR_CODE)
    expect(LoginItem.find(@login_item.id).last_webhook_sent_at).not_to be_nil
    expect(LoginItem.find(@login_item.id).expired).to eq(true)
    expect(LoginItem.find(@login_item.id).expired_at).not_to be_nil
  end
end
