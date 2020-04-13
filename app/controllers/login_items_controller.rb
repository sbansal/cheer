class LoginItemsController < ApplicationController
  def index
    @login_items = current_user.login_items
  end

  def destroy
    @login_item = current_user.login_items.find(params[:id])
    @login_item.destroy
    respond_to do |format|
      format.html { redirect_to login_items_path }
      format.json { head :no_content }
    end
  end
end
