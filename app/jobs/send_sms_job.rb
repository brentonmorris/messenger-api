class SendSmsJob
  include Sidekiq::Job

  sidekiq_options retry: 3, queue: "sms"

  def perform(message_id)
    Rails.logger.info "Starting SMS job for message_id: #{message_id}"

    message = Message.find(message_id)
    Rails.logger.info "Sending SMS: #{message.recipient} - '#{message.content[0..50]}...'"

    response = TwilioSmsService.send_message(
      to: message.recipient,
      body: message.content
    )

    # Update message with Twilio response
    update_attributes = {
      status: map_twilio_status_to_internal_status(response[:status]),
      twilio_status: response[:status]
    }

    if response[:success]
      update_attributes[:message_sid] = response[:message_sid]
      Rails.logger.info "SMS sent successfully for message #{message_id}. SID: #{response[:message_sid]}"
    else
      update_attributes[:error_message] = response[:error]
      update_attributes[:failed_at] = Time.current
      Rails.logger.error "Failed to send SMS for message #{message_id}: #{response[:error]}"
    end

    message.update!(update_attributes)
  end

  private

  # Map Twilio status to internal single-word status for UI display
  def map_twilio_status_to_internal_status(twilio_status)
    case twilio_status
    when 'queued', 'accepted'
      'queued'
    when 'sending'
      'sending'
    when 'sent'
      'sent'
    when 'delivered'
      'done'
    when 'failed', 'undelivered'
      'failed'
    else
      'queued' # default for unknown statuses
    end
  end
end
