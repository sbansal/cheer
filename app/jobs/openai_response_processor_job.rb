class OpenaiResponseProcessorJob < ApplicationJob
  queue_as :openai

  def perform(chat_id)
    ChatbotService.call(chat_id)
  end
end
