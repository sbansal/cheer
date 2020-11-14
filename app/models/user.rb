class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
  :recoverable, :rememberable, :validatable, :trackable

  has_one_attached :avatar
  has_many :login_items, dependent: :destroy
  has_many :bank_accounts, dependent: :destroy
  has_many :transactions, ->{ order(:occured_at => 'DESC') }, dependent: :destroy
  has_many :subscriptions, dependent: :destroy

  belongs_to :account

  validates :full_name, presence: { message: 'Please provide your full name.' }

  def friendly_name
    full_name&.split(' ')&.first || 'there'
  end

  def send_devise_notification(notification, *args)
    devise_mailer.send(notification, self, *args).deliver_later
  end

  def activated?
    sign_in_count > 0
  end

  def new_account?
    account.login_items.empty?
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
    bank_accounts.includes(:balances).assets.map { |account| account.balance || 0 }.sum
  end

  def total_liabilities
    bank_accounts.includes(:balances).liabilities.map { |account| account.balance || 0 }.sum
  end

  def net_worth
    total_assets - total_liabilities
  end
end

