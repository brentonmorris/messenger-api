class TwilioSmsService
  attr_reader :client, :from_number

  def initialize
    account_sid = ENV["TWILIO_ACCOUNT_SID"]
    auth_token = ENV["TWILIO_AUTH_TOKEN"]
    @from_number = ENV["TWILIO_PHONE_NUMBER"]

    raise "Twilio credentials not configured" if account_sid.blank? || auth_token.blank? || @from_number.blank?

    @client = Twilio::REST::Client.new(account_sid, auth_token)
  end

  def send_sms(to:, body:)
    callback_url = status_callback_url
    Rails.logger.info "Sending SMS to #{to}"

    begin
      message = client.messages.create(
        from: from_number,
        to: to,
        body: body,
        status_callback: callback_url
      )

      Rails.logger.debug "SMS sent successfully. SID: #{message.sid}"

      {
        success: true,
        message_sid: message.sid,
        status: message.status,
        error: nil
      }
    rescue Twilio::REST::RestError => e
      Rails.logger.error "Twilio error: #{e.message}"

      {
        success: false,
        message_sid: nil,
        status: "failed",
        error: e.message
      }
    rescue => e
      Rails.logger.error "Unexpected error sending SMS: #{e.message}"

      {
        success: false,
        message_sid: nil,
        status: "failed",
        error: "Unexpected error: #{e.message}"
      }
    end
  end

  def self.send_message(to:, body:)
    new.send_sms(to: to, body: body)
  end

  private

  def status_callback_url
    base_url = ENV["APP_BASE_URL"] || "https://your-app-domain.com"
    "#{base_url}/api/twilio/message-status-callback"
  end
end
