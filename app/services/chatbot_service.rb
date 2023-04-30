class ChatbotService < ApplicationService
  attr_reader :chat, :message

  def initialize(message)
    @message = message
  end

  def fetch_response
    "PrivateFi is here to help you manage your finances."
  end
end

