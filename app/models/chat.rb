class Chat < ApplicationRecord
  has_many :messages, ->{ order(:created_at => 'ASC') }, dependent: :destroy

  def broadcast_tag
    "chat-#{id}-messages"
  end

  SYSTEM_PROMPT = "Your name is PrivateFi and you help people answer question about their finances. 
  If you are asked a question about anything unrelated to finance, you will respond politely and concisely asking the user to ask something related to their finances."
  def messages_for_openai
    openai_messages = [{ content: SYSTEM_PROMPT, role: "system"}]
    openai_messages += messages.map { |message| { role: message.role, content: message.content } }.last(5)
  end
end
