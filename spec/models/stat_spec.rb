require 'rails_helper'

RSpec.describe Stat, type: :model do
  it 'has a unique name for an account' do
    account = create(:account)
    name = 'cashflow'
    create(:stat, name: name, account: account)
    expect {
      create(:stat, name: name, account: account)
    }.to raise_exception(ActiveRecord::RecordNotUnique)
  end
end
