class User < ApplicationRecord
  encrypts :otp_secret

  devise :database_authenticatable, :registerable, :confirmable,
  :recoverable, :rememberable, :validatable, :trackable, :timeoutable

  attr_accessor :otp_attempt
  has_many :login_items, dependent: :destroy
  has_many :bank_accounts, ->{ order(:created_at => 'DESC') }, dependent: :destroy
  has_many :transactions, ->{ order(:occured_at => 'DESC') }, dependent: :destroy
  has_many :subscriptions, dependent: :destroy

  belongs_to :company

  validates :full_name, presence: { message: 'Please provide your full name.' }

  #callback
  before_destroy :delete_stripe_customer_link

  def friendly_name
    full_name&.split(' ')&.first || 'there'
  end

  def send_devise_notification(notification, *args)
    devise_mailer.send(notification, self, *args).deliver_later unless Rails.env.test?
  end

  def activated?
    sign_in_count > 0
  end

  def new_company?
    sign_in_count == 1 || company.bank_accounts.empty?
  end

  def invite_person(email, full_name)
    self.email = email
    self.full_name = full_name
    self.password = Devise.friendly_token
    self.skip_confirmation!
  end

  def send_invitation_message(invitee_name)
    GenericMailer.invite_person_email(id, invitee_name).deliver_later
  end

  def regenerate_password_token
    raw_token, hashed_token = Devise.token_generator.generate(User, :reset_password_token)
    self.reset_password_token = hashed_token
    self.reset_password_sent_at = Time.now.utc
    self.save
    raw_token
  end

  def historical_cashflow(start_date=Time.zone.now.beginning_of_year, end_date=Time.zone.now)
    HistoricalCashflow.new(start_date, end_date, transactions.includes(:category))
  end

  def accounts_count
    login_items.map { |item| item.bank_accounts.count }.sum
  end

  def process_recurring_transactions
    bank_accounts.map { |bank_account| bank_account.create_recurring_transactions }
  end

  def this_month_transactions
    transactions.occured_between(Time.zone.now.beginning_of_month, Time.zone.now).includes(:category)
  end

  def last_transaction_pulled_at
    transactions&.first&.occured_at || 1.month.ago.to_date
  end

  def total_assets
    bank_accounts.assets.sum(:current_balance)
  end

  def total_liabilities
    bank_accounts.liabilities.sum(:current_balance)
  end

  def net_worth
    total_assets - total_liabilities
  end

  def send_two_factor_auth_notification
    GenericMailer.two_factor_auth_notification(id).deliver_later
  end

  def two_factor_enabled?
    !self.otp_secret.blank?
  end

  def two_factor_status
    if two_factor_enabled?
      "ON"
    else
      "OFF"
    end
  end

  def verify_otp_attempt?(otp_attempt)
    last_otp_at = OtpVerifier.verify_otp_attempt(self.otp_secret, otp_attempt, self.last_otp_at)
    if last_otp_at
      self.update(last_otp_at: last_otp_at)
      true
    else
      false
    end
  end

  def after_database_authentication
    Sentry.set_user(id: id)
  end

  ACTIVE_STRIPE_SUBSCRIPTION_STATES = ['trialing', 'active']
  PENDING_STRIPE_SUBSCRIPTION_STATES = [ 'past_due', 'unpaid']
  EXPIRED_STRIPE_SUBSCRIPTION_STATES = ['canceled', 'incomplete', 'incomplete_expired']

  def has_no_subscription?
    !self.beta_tester && self.subscription_status.nil?
  end
  
  def has_expired_subscription?
    !self.beta_tester && EXPIRED_STRIPE_SUBSCRIPTION_STATES.include?(self.subscription_status)
  end

  def has_pending_subscription?
    !self.beta_tester && PENDING_STRIPE_SUBSCRIPTION_STATES.include?(self.subscription_status)
  end

  def has_active_subscription?
    self.beta_tester || ACTIVE_STRIPE_SUBSCRIPTION_STATES.include?(self.subscription_status)
  end

  def update_subscription_details(subscription)
    update({
      stripe_subscription_id: subscription.id,
      stripe_pricing_plan: subscription.items.data.first.price.id,
      last_payment_processed_at: Time.at(subscription.current_period_start),
      next_payment_at: Time.at(subscription.current_period_end),
      subscription_status: subscription.status,
      subscription_cancel_at: subscription.cancel_at ? Time.at(subscription.cancel_at) : nil,
      subscription_canceled_at: subscription.canceled_at ? Time.at(subscription.canceled_at) : nil,
    })
  end

  private

  def delete_stripe_customer_link
    if self.stripe_customer_id
      Rails.logger.info("[User][Destroy] Deleting the customer from the stripe platform with ID - #{self.stripe_customer_id}")
      StripeCustomerDeleter.call(self.stripe_customer_id)
    else
      Rails.logger.info("[User][Destroy] Ignoring stripe customer deletion. The user does not have a stripe customer ID.")
    end
  end
end

