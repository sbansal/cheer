class MessagesController < ApplicationController
  def create
    @chat = current_user.chats.find(params[:chat_id])
    @message = @chat.messages.build(message_params.merge(role: "user", user_id: current_user.id))

    respond_to do |format|
      if @message.save
        @message.broadcast_created
        OpenaiResponseProcessorJob.perform_later(@chat.id)
        format.turbo_stream
      end
    end
  end

  private
    def message_params
      params.require(:message).permit(:content)
    end
end