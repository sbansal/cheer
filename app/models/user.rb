class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

 def has_no_posts?
   true
 end
 
 def friendly_name
   full_name.split(' ')&.first
 end
end
