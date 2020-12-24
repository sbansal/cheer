class OtpVerifier

  def self.verify_during_setup(otp_secret, otp_code)
    totp = ROTP::TOTP.new(otp_secret, issuer: Rails.application.credentials[:app_name])
    last_otp_at = totp.verify(otp_code)
  end

  def self.verify_otp_attempt(otp_secret, otp_attempt, last_otp_at)
    totp = ROTP::TOTP.new(otp_secret, issuer: Rails.application.credentials[:app_name])
    last_otp_at = totp.verify(otp_attempt, after: last_otp_at)
  end

end