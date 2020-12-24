class OtpGenerator < ApplicationService
  def initialize(email_address)
    @email = email_address
    @otp_secret = ROTP::Base32.random
    @totp = ROTP::TOTP.new(@otp_secret, issuer: Rails.application.credentials[:app_name])
  end

  def call
    @qr_code = RQRCode::QRCode.new(@totp.provisioning_uri(@email)).as_png(resize_exactly_to: 200).to_data_url
    return @qr_code, @otp_secret
  end
end
