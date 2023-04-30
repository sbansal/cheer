class Chat < ApplicationRecord
  has_many :messages, dependent: :destroy

  def broadcast_tag
    "chat-#{id}-messages"
  end
end
