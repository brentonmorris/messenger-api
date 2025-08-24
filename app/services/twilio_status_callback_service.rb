class TwilioStatusCallbackService
  def initialize(params)
    @params = params
    @message_sid = params[:MessageSid]
    @message_status = params[:MessageStatus]
    @error_code = params[:ErrorCode]
  end

  def call
    Rails.logger.info "Processing Twilio status callback for MessageSid: #{@message_sid}, Status: #{@message_status}"

    return failure("Missing required parameters") unless valid_params?

    message = find_message
    return failure("Message not found for MessageSid: #{@message_sid}") unless message

    update_message(message)
    success("Message #{message.id} updated with status: #{@message_status}")
  rescue => e
    Rails.logger.error "Error processing status callback for MessageSid #{@message_sid}: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    failure("Error updating message: #{e.message}")
  end

  private

  def valid_params?
    @message_sid.present? && @message_status.present?
  end

  def find_message
    Message.find_by(message_sid: @message_sid)
  end

  def update_message(message)
    update_attributes = build_update_attributes
    message.update!(update_attributes)
  end

  def build_update_attributes
    attributes = {
      twilio_status: @message_status,
      status: map_twilio_status_to_internal_status(@message_status)
    }

    # Handle error information
    if @error_code.present?
      attributes[:error_code] = @error_code
      attributes[:error_message] = @params[:ErrorMessage] if @params[:ErrorMessage].present?
    end

    # Handle additional Twilio fields for different message types
    add_optional_fields(attributes)

    # Set timestamps based on status
    add_status_timestamps(attributes)

    attributes
  end

  def add_optional_fields(attributes)
    optional_fields = {
      raw_dlr_done_date: :RawDlrDoneDate,
      channel_install_sid: :ChannelInstallSid,
      channel_status_message: :ChannelStatusMessage,
      channel_prefix: :ChannelPrefix,
      event_type: :EventType
    }

    optional_fields.each do |attr_key, param_key|
      attributes[attr_key] = @params[param_key] if @params[param_key].present?
    end
  end

  def add_status_timestamps(attributes)
    case @message_status
    when "sent"
      attributes[:sent_at] = Time.current
    when "delivered"
      attributes[:delivered_at] = Time.current
    when "failed", "undelivered"
      attributes[:failed_at] = Time.current
    end
  end

  def map_twilio_status_to_internal_status(twilio_status)
    case twilio_status
    when "queued", "accepted"
      "queued"
    when "sending"
      "sending"
    when "sent"
      "sent"
    when "delivered"
      "done"
    when "failed", "undelivered"
      "failed"
    else
      "unknown"
    end
  end

  def success(message)
    Rails.logger.info message
    {success: true, message: message}
  end

  def failure(message)
    Rails.logger.warn message
    {success: false, error: message}
  end
end
