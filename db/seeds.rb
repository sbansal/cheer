# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
require 'csv'

user = User.find_or_create_by(email: 'shubhambansal15@gmail.com')
CSV.foreach(Rails.root.join('lib/assets/transactions_amazon_seeds.csv'), headers: true) do |row|
  # puts "transaction_date:#{row[0]}, post_date:#{row[1]}"
  Transaction.create({
    transaction_date: Date.strptime(row[0], '%m/%d/%Y'), 
    post_date: Date.strptime(row[1], '%m/%d/%Y'), 
    description: row[2], 
    category: row[3]&.downcase, 
    transaction_type: row[4]&.downcase, 
    amount: row[5],
    user_id: user.id,
  })
end

CSV.foreach(Rails.root.join('lib/assets/transactions_amex_seeds.csv'), headers: true) do |row|
  Transaction.create({
    transaction_date: Date.strptime(row[0], '%m/%d/%y'),
    post_date: Date.strptime(row[0], '%m/%d/%y'),
    description: row[1],
    amount: row[4],
    category: row[9]&.downcase,
    user_id: user.id,
  })
end