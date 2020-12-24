class OtpVerifier

  def self.verify_during_setup(otp_secret, otp_code)
    totp = ROTP::TOTP.new(otp_secret, issuer: Rails.application.credentials[:app_name])
    last_otp_at = totp.verify(otp_code)
  end


end