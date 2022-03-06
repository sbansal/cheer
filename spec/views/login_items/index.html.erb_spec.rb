require 'rails_helper'

RSpec.describe "login_items/index" do
  before(:all) do
    @user = create(:user)
    @user.confirm
    sign_in @user
  end

  it 'display all the login item' do
    login_item = create(:login_item, user: @user)
    assign(:login_items, [login_item])
    institution_name = login_item.institution.name
    render
    expect(rendered).to match("#{institution_name}")
  end

  it 'connects the plaid controller' do
    assign(:login_items, [])
    render
    expect(rendered).to match("data-controller=\"plaid\"")
  end
end
