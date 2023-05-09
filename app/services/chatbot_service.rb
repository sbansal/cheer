class ChatbotService < ApplicationService
  attr_reader :chat

  def initialize(chat_id)
    @chat = Chat.find(chat_id)
  end

  def call
    call_openai
  end

  private
  require 'openai'

  def call_openai
    message = @chat.messages.create(role: "assistant", content: "", user: User.privatefi, query_type: Message::BOT_RESPONSE)
    message.broadcast_created

    begin
      client = OpenAI::Client.new(access_token: Rails.application.credentials[:openai][:api_access_token])
      client.chat(
        parameters: {
          model: "gpt-3.5-turbo",
          messages: @chat.messages_for_openai,
          temperature: 0.1,
          stream: stream_proc(message: message)
        }
      )
    rescue => e
      Rails.logger.error(e)
      message.update(content: "Sorry, I'm having trouble understanding you. Please try again.")
    end
  end

  def stream_proc(message:)
    proc do |chunk, _bytesize|
      new_content = chunk.dig("choices", 0, "delta", "content")
      message.update(content: message.content + new_content) if new_content
    end
  end
end

