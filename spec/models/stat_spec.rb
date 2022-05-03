require 'rails_helper'

RSpec.describe Stat, type: :model do
  it 'has a unique name for a company' do
    company = create(:company)
    name = 'cashflow'
    create(:stat, name: name, company: company)
    expect {
      create(:stat, name: name, company: company)
    }.to raise_exception(ActiveRecord::RecordNotUnique)
  end

  it 'fetch historical trend since a date' do
    stat = create(:stat, name: Stat::INCOME_STAT)
    expect(stat.fetch_historical_trend_since(Date.today - 10.days).count).to eq(11)
  end
end
