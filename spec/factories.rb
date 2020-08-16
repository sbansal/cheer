FactoryBot.define do
  factory :account do
    name { "SB account" }

    factory :account_with_users do
      after(:create) do |account|
        create_list(:user, 1, account: account)
      end
    end
  end

  factory :balance do
    available { 1.5 }
    current { 1.5 }
    limit { 1.5 }
    currency_code { "MyString" }
    bank_account_id { 1 }
    user_id { 1 }
  end

  factory :user do
    full_name { "Joe Black" }
    sequence :email do |n|
      "#{SecureRandom.hex(8)}@example.com"
    end
    password { "blahblah" }
    account

    factory :user_with_transactions do
      transient do
        transactions_count { 10 }
      end

      after(:create) do |user, evaluator|
        create_list(:transaction, evaluator.transactions_count, user: user)
      end
    end
  end

  factory :institution do
    plaid_institution_id { 'ins_2382' }
    name { 'Chase' }
    logo {'iVBORw0KGgoAAAANSUhEUgAAAJgAAACYCAMAAAAvHNATAAAANlBMVEVHcEwOW6f///8IVqUPW6gQXKgRXKkPW6gTYKwPW6gbYqsxcbJ3ocza5vDs8/b0+Pmlwt1Vir96WNmQAAAACnRSTlMA////5HhLoCDGuAtrFAAABQNJREFUeNrt3H9vpCAQBuACIuC6wn7/L3vuXttb8UX5MdjJpVya3D9tngDiqDPz8dE67KiNcc4NgxDDsP7HGD3aj58cVhu3avAYnNE/wbOjSZredObauctCveGuWsAC1aet/6Ja7UTVcF1t1oiGYSxLVjdaO6sLjYZFT9OTIBuTpju2nCAdbmS2irTrOQ6iwxiaJ02LTqNtp9n07lJT7kjtNNtjGdUt3JfMMSvq5Uwvo3osMn+kZLXLaTDp9jyL7rJkBJGgGTKXeCw3teqKXH6VCTKZw/Pl/RM2y8KRnDNHcjk+t1YdTIZJUVycdsCX4rrlK2Fp2WBb11Hcnlu+FibvU/tq4nV8uaphXt5vrTJz4KqfMemTMtNyTny6GmBStsnwef99pLbA5JKSZdwDRnzH/j7qm2ByeSRkY9VBoaYgKWA+LTs9NNAFqUSQkmbG1t9PyFzNBguSDiZ9ItjQxRts42qHJWVj6QYLkhaWCtAOtpk5d5HAEjJTtJCxgQSWCNDG/CtyT6CB4QDNZV+RQEAEwzJ4ZdoJBazdYDBAm2zWzkcuOhgM0MD+t3kuQphHMns+YYlnRzoYDNDM6YS9Avy+MBig2bMJS7hoYUBmjifsK5DuDQNhkD2asLSLGuZ3MnMwYQcuahiYM5s+9NdA2l8G24WOOnWXVIfvcuhhcYDmEiv5HuBfA4vDIAtX8uXyJ7DHnXg88FoOyUAaw8REPjahLAwQg8yArSFL0b+/v5L8UYmA0aQD6RSs7zC7lVx3te8CU2dDgLW04A0FMWwKx2OO/qiNt1gnmLqdrUP0MWCMt1g32FJ2/Jv4sPg5mAwq3mRWsIDdp3iTaY4wHYVibGAmiizYwFx0o2QDe+5+wREmoliMD8xuQws+sHEb7vOB6e2DGx+Y4QtzPGHuF1YMG3jCBr4wwRMm+MJ+91gp7Pcc+29gv9FFKYxtoMg2tGb7MML28Y3vAy/bVwRsX6qwfQ3F9sUdk1edG9jA5+XwFmbi1+mKCWyMP0BkfO+7BGb3H98CB9gAvtRP890fjqUTbJn2H7m2eWPT7XjUfOLK+DLyPmMj/JAqSr6TkcHeM0OG/jU+2bDNBtHwY70iHxmwbe6FRekN6jETj+fH/RPY1uVwQsitrIAmK3XhBBZlhGicQnOSdtEBFmeq2FTSEbHsDBYnEpuDNK1wHczvknXtUWJbuG7GZnWcC7hN71HhKtiszrInzVY2XwML6jTf1J7kWHeBhdPcSZANOPvusH1as8lIacb5uZSwkJfSvLuVE8mSMJBsrfPS5svqTkthwOVyCw1IZBDmYQr4mFuaoRTBLR3PWGZqerKYhUAGYagK7qhmahT0MgSD1XljWcFUswzAoEuXlpg9AzRPCoNPgK6iKK8tQNvBYF3eeSXvKIhlMQzXC45VhZ+qJUCLYLhaUNeWyjYEaFsYdjUU8dbLtrC5wYVrzapDx3cYrmBsLRSf606Nd1irK1FoObfCoGsoa0YAa3mrArR/sADnq7SDCZYtDbDQuo5H12aF7AsG6xapWoSoCtknDNagVrnw+7zyYOMF87DdRXXvHtgep1D2Kn65IVdLtyN0cRbO2WvLT8Dl2vpD6TbZkuw/09zsCyynmkrec8IxEHT6svDqzH8zDK9GmrZt1Y3RUj1U6Do+Mm0lx7j5Ht92hYwbPDJuicm4iSjjtqucG9Vybu37vagMmyG/z12X9tF/APITr9CCbDsMAAAAAElFTkSuQmCC'}
    url { 'https://www.chase.com' }
  end

  factory :login_item do
    plaid_item_id { SecureRandom.hex(32) }
    plaid_access_token { SecureRandom.hex(32) }
    consent_expires_at {}
    error_json {}
    last_successful_transaction_update_at { Time.zone.now }
    last_failed_transaction_update_at {}
    last_webhook_sent_at {}
    last_webhook_code_sent {}
    expired_at { }
    expired { false }
    public_token {}
    public_token_expired_at {}
    user
    institution
  end

  factory :bank_account do
    plaid_account_id { SecureRandom.hex(32) }
    name { 'Chase Credit Card'}
    official_name { 'Chase Something Platinum' }
    account_type { 'credit' }
    account_subtype { 'credit card' }
    mask { '1111' }
    balance_available { 1000 }
    balance_limit { 2000 }
    balance_currency_code { 'USD' }
    login_item
    user
  end

  factory :category do
    group { 'special' }
    hierarchy { ["Food and Drink", "Restaurants", "Fast Food"] }
    plaid_category_id { SecureRandom.hex(8) }
    rank { '3' }
    essential { true }
    descriptive_name { 'Food and Drink' }
  end

  factory :transaction do
    plaid_transaction_id { SecureRandom.hex(32) }
    amount { 25 }
    currency_code { 'USD' }
    occured_at { Date.today }
    authorized_at { Date.today }
    location_json {}
    description { 'Madison Bicycle Shop' }
    transaction_type { 'place' }
    payment_meta_json {}
    payment_channel { 'in store' }
    pending { false }
    plaid_pending_transaction_id { SecureRandom.hex(32) }
    transaction_code {}
    user
    bank_account
    category
  end
end