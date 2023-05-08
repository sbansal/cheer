class Chat < ApplicationRecord
  has_many :messages, ->{ order(:created_at => 'ASC') }, dependent: :destroy

  def broadcast_tag
    "chat-#{id}-messages"
  end

  def messages_for_openai
    openai_messages = [{ content: "Your name is PrivateFi and you help people answer question about their finances only.", role: "system"}]
    openai_messages += messages.map { |message| { role: message.role, content: message.content } }.last(5)
  end
end
