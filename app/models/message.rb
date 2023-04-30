class Message < ApplicationRecord
  belongs_to :chat
  belongs_to :user

  BOT_RESPONSE = 'bot_response'
  HUMAN_PROMPT = 'prompt'

  def human_prompt?
    self.query_type == HUMAN_PROMPT
  end

  def bot_response?
    self.query_type == BOT_RESPONSE
  end

  def broadcast_message
    style = self.human_prompt? ? '' : 'generated-text'
    broadcast_append_to self.chat.broadcast_tag, partial: 'messages/message', locals: {message: self, style: style}
    fetch_bot_response if self.human_prompt?
  end

  def fetch_bot_response
    response = ChatbotService.new(self).fetch_response
    privatefi = User.privatefi
    message = Message.create!(user: privatefi, chat: self.chat, content: response, query_type: BOT_RESPONSE)
    message.broadcast_message
  end

end
