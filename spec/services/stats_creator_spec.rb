require 'rails_helper'

RSpec.describe StatsCreator do
  before(:all) do
    @user = create(:user)
  end


  it 'creates the net worth stat' do
    stat_name = Stat::NET_WORTH_STAT
    stat = StatsCreator.call(@user.account.id, stat_name)
    expect(stat.description).to eq(Stat::SUPPORTED_STATS[stat_name])
  end

  it 'does not create a stat for an unknown stat name' do
    expect(StatsCreator.call(@user.account.id, 'randow_stat')).to be_nil
  end

end
