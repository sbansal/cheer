require 'rails_helper'

RSpec.describe Transaction::CategorizedTransaction, type: :model do
  describe '#monthly_spend' do
    let(:category) { create(:category) }
    let(:transactions) do
      [
        create(:transaction, occured_at: '2022-01-01', amount: 100, category: category),
        create(:transaction, occured_at: '2022-01-15', amount: 200, category: category),
        create(:transaction, occured_at: '2022-02-01', amount: 300, category: category),
      ]
    end
    let(:categorized_transaction) { described_class.new(category, transactions) }

    it 'returns a hash with the total spend for each month' do
      expect(categorized_transaction.monthly_spend).to eq({
        Date.new(2022, 1, 1) => 300, # January
        Date.new(2022, 2, 1) => 300
      })
    end
  end
end