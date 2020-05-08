require 'rails_helper'

RSpec.describe Category, type: :model do
  require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

  before(:all) do
    @category_root = create(:category, hierarchy: ["Transfer"])
    @category_sec = create(:category, hierarchy: ["Transfer", "Third Party"])
    @category = create(:category, hierarchy: ["Transfer", "Third Party", "Chase QuickPay"])
  end
  
  it 'has 3 categories' do
    expect(Category.all.count).to eq 3
  end
  
  it 'has category list' do
    expect(@category.category_list).to eq 'Transfer, Third Party, Chase QuickPay'
  end
  
  it 'is a charge' do
    expect(@category.charge?).to be true
  end
  
  it 'is not a charge' do
    category = build(:category, hierarchy: ["Transfer", "Internal Account Transfer", "Chase QuickPay"])
    expect(category.charge?).to be false
  end
  
  it 'has a root name' do
    expect(@category.root_name).to eq 'Transfer'
  end
  
  it 'has a secondary name' do
    expect(@category.secondary_names).to eq ["Third Party", "Chase QuickPay"]
  end
  
  it 'has empty secondary name' do
    expect(@category_root.secondary_names).to eq []
  end
  
  it 'has a parent category' do
    expect(@category.parent).to eq @category_sec
    expect(@category_sec.parent).to eq @category_root
  end
  
  it 'has children' do
    expect(@category_root.children.count).to eq 2
    expect(@category_sec.children.count).to eq 1
  end
  
  after(:all) do
    Category.destroy_all
  end

end
