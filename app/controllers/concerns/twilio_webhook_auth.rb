module TwilioWebhookAuth
  extend ActiveSupport::Concern

  private

  # Verify that the request is actually from Twilio
  def verify_twilio_signature
    # Skip validation in development and test modes (ngrok proxy interferes with signature validation)
    if Rails.env.development? || Rails.env.test?
      Rails.logger.info "Skipping Twilio signature validation in #{Rails.env} mode"
      return
    end

    auth_token = ENV["TWILIO_AUTH_TOKEN"]
    return head :unauthorized unless auth_token

    signature = request.headers["X-Twilio-Signature"]
    return head :unauthorized unless signature

    validator = Twilio::Security::RequestValidator.new(auth_token)

    url = request.original_url
    body = request.raw_post || ""

    if body.empty? && request.request_parameters.present?
      body = URI.encode_www_form(request.request_parameters.sort)
    end

    unless validator.validate(url, body, signature)
      Rails.logger.warn "Invalid Twilio signature for webhook"
      head :unauthorized
    end
  end
end
