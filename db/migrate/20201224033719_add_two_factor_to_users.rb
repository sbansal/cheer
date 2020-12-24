class AddTwoFactorToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :otp_secret_ciphertext, :text
    add_column :users, :last_otp_at, :integer
  end
end
