class SessionsController < Devise::SessionsController
  include AuthenticatesWithTwoFactor
  prepend_before_action :authenticate_with_two_factor, if: -> { action_name == 'create' && otp_two_factor_enabled? }

  protect_from_forgery with: :exception, prepend: true, except: :destroy

end