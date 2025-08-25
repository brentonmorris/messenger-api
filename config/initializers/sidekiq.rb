Sidekiq.configure_server do |config|
  config.redis = {
    url: ENV.fetch("REDIS_URL", "redis://localhost:6379/0"),
    network_timeout: 5,
    ssl_params: {verify_mode: OpenSSL::SSL::VERIFY_NONE}
  }
  config.concurrency = 5
  config.queues = %w[default sms]
end

Sidekiq.configure_client do |config|
  config.redis = {
    url: ENV.fetch("REDIS_URL", "redis://localhost:6379/0"),
    network_timeout: 5,
    ssl_params: {verify_mode: OpenSSL::SSL::VERIFY_NONE}
  }
end

Sidekiq.logger.level = Logger::INFO if Rails.env.production?
