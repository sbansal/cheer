class MessagesController < ApplicationController
  def create
    @chat = current_user.chats.find(params[:chat_id])
    @message = @chat.messages.build(message_params)
    @message.user = current_user

    respond_to do |format|
      if @message.save
        @message.broadcast_message
        format.turbo_stream
      end
    end
  end

  private
    def message_params
      params.require(:message).permit(:content)
    end
end