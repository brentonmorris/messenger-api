class ApplicationMailer < ActionMailer::Base
  default from: "noreply@example.com"

  def mail(headers = {}, &block)
    DummyMail.new
  end

  private

  class DummyMail
    def deliver_now
      Rails.logger.info "Email delivery skipped (API-only mode)"
    end

    def deliver_later
      Rails.logger.info "Email delivery skipped (API-only mode)"
    end

    def deliver
      Rails.logger.info "Email delivery skipped (API-only mode)"
    end
  end
end
