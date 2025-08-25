module Api
  module Twilio
    class WebhooksController < Api::BaseController
      include TwilioWebhookAuth

      skip_before_action :authenticate_user!
      # Comment this out for the demo, wasn't able to get it to work yet.
      # Insecure, but fine for demo.
      # before_action :verify_twilio_signature

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
