class TwoFactorAuthenticationController < ApplicationController
  def new
    @qr_code, @otp_secret = OtpGenerator.call(current_user.email)
    respond_to do |format|
      format.js
    end
  end

  def create
    @otp_secret = params[:otp_secret]
    @last_otp_at = OtpVerifier.verify_during_setup(@otp_secret, params[:otp_code])
    if @last_otp_at.present?
      current_user.update(otp_secret: @otp_secret, last_otp_at: @last_otp_at)
      redirect_to accounts_settings_path, flash: { notice_header: 'Two Factor authentication enabled',
        notice: 'You have enabled two factor authentication and added an extra layer of security to your account.'}
    else
      @alert = 'The code you entered did not work. Please try again.'
      respond_to do |format|
        format.js
      end
    end
  end

  def destroy
    current_user.update(otp_secret: nil, last_otp_at: nil)
    redirect_to accounts_settings_path, flash: { notice_header: 'Two Factor authentication disabled.',
      notice: 'Your account does not have an extra layer of protection.'}
  end
end
