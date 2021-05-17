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
    expect(stat.value_over_time_data).to eq({
      Stat::THIS_MONTH => 0,
      Stat::LAST_MONTH => 0,
      Stat::QUARTERLY => 0,
      Stat::YEARLY => 0,
      Stat::ALL => 0,
    })
  end

  it 'creates all stats' do
    StatsCreator.call(@user.account.id, 'ALL')
    expect(@user.account.stats.count).to eq(10)
  end

end
