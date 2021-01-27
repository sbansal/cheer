class OnboardingController < ApplicationController
  layout 'intro'
  def index
    @login_items = current_account.login_items
  end
end
