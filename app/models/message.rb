class Message
  include Mongoid::Document
  include Mongoid::Timestamps

  field :content, type: String
  field :sender, type: String
  field :recipient, type: String
  field :user_id, type: BSON::ObjectId

  # SMS status tracking fields
  field :status, type: String, default: "queued"
  field :message_sid, type: String
  field :twilio_status, type: String
  field :sent_at, type: Time
  field :failed_at, type: Time
  field :error_message, type: String
  field :error_code, type: String
  field :delivered_at, type: Time

  # Additional Twilio callback fields
  field :raw_dlr_done_date, type: String
  field :channel_install_sid, type: String
  field :channel_status_message, type: String
  field :channel_prefix, type: String
  field :event_type, type: String

  # Indexes
  index({ message_sid: 1 }, { unique: true, sparse: true })

  belongs_to :user

  # Callbacks
  after_create :enqueue_sms_job

  private

  def enqueue_sms_job
    SendSmsJob.perform_async(id.to_s)
  end
end
