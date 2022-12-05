class PlaidController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:update_link, :generate_access_token, :create_link_token]

  def update_link
    @login_item = current_user.login_items.find_by(link_token: params['link_token'])
    @login_item.activate
    PlaidLoginItemUpdaterJob.perform_later(@login_item.id)
    flash[:notice_header] = 'Link updated'
    flash[:notice] = "Your link to #{@login_item.institution.name} has been renewed successfully."
  end

  def generate_access_token
    access_token = PlaidPublicTokenExchanger.call(params['public_token'])
    @login_item = PlaidLoginItemCreator.call(access_token, current_user)
    flash[:notice_header] = 'New link created'
    flash[:notice] = "You have successfully linked your #{@login_item.institution.name} accounts to Cheer."
  end

  def create_link_token
    response = PlaidLinkTokenCreator.call(current_user.id)
    respond_to do |format|
      format.json { render json: {link_token: response.link_token} }
    end
  end
end
