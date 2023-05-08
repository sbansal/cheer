class Message < ApplicationRecord
  belongs_to :chat
  belongs_to :user

  enum role: { system: 0, assistant: 10, user: 20 }

  BOT_RESPONSE = 'bot_response'
  HUMAN_PROMPT = 'prompt'

  after_update_commit -> { broadcast_updated }

  def human_prompt?
    self.query_type == HUMAN_PROMPT
  end

  def bot_response?
    self.query_type == BOT_RESPONSE
  end

  def broadcast_created
    style = self.human_prompt? ? '' : 'generated-text'
    broadcast_append_to self.chat.broadcast_tag, partial: 'messages/message', locals: {message: self, style: style}
  end

  def broadcast_updated
    broadcast_replace_to self.chat.broadcast_tag, partial: 'messages/message', locals: {message: self, style: 'generated-text'}
  end

end
