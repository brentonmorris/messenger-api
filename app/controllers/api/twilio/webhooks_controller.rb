module Api
  module Twilio
    class WebhooksController < Api::BaseController
      include TwilioWebhookAuth

      skip_before_action :authenticate_user!
      before_action :verify_twilio_signature

      # POST /api/twilio/message-status-callback
      def message_status_callback
        TwilioStatusCallbackService.new(params).call
        head :ok
      rescue => e
        Rails.logger.error "Twilio message status callback failed: #{e.message}"
        Rails.logger.error e.backtrace.join("\n")
        head :ok # Still return 200 to prevent Twilio retries for non-recoverable errors
      end
    end
  end
end
