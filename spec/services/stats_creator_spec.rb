require 'rails_helper'

RSpec.describe StatsCreator do
  before(:all) do
    @user = create(:user)
  end

  it 'creates the net worth stat' do
    expect(@user.account.stats.count).to eq(0)
    stat_name = Stat::NET_WORTH_STAT
    stat = StatsCreator.call(@user.account.id, stat_name)
    expect(stat.description).to eq(Stat::SUPPORTED_STATS[stat_name])
    expect(@user.account.stats.count).to eq(1)
  end

  it 'creates all stats' do
    StatsCreator.call(@user.account.id, 'ALL')
    expect(@user.account.stats.count).to eq(5)
  end

end
