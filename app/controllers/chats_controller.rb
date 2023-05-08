class ChatsController < ApplicationController

  def show
    @chat = current_user.chats.find(params[:id])
    @messages = @chat.messages
  end

  def destroy
    @chat = current_user.chats.find(params[:id])
    @chat.messages.delete_all
    redirect_to @chat
  end

  private
  def chat_params
    params.require(:chat).permit(:content)
  end
end
