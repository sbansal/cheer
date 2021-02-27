# Be sure to restart your server when you modify this file.

# Configure sensitive parameters which will be filtered from the log file.
Rails.application.config.filter_parameters += [
  :passw, :secret, :token, :_key, :crypt, :salt, :certificate, :otp, :ssn,
  # user
  :email, :full_name, :confirmation_token, :unconfirmed_email, :current_sign_in_ip, :last_sign_in_ip,
  # login_items
  :plaid_access_token,
  #bank_account
  :balance_available, :balance_limit, :current_balance, :mask
]
