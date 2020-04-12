class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_one_attached :avatar
  has_many :login_items
  has_many :bank_accounts
  has_many :transactions, ->{ order(:occured_at => 'DESC') }
  
  def has_no_posts?
    true
  end

 def friendly_name
   full_name.split(' ')&.first
 end
end
