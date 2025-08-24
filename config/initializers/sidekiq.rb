# Sidekiq configuration
Sidekiq.configure_server do |config|
  config.redis = {
    url: ENV.fetch("REDIS_URL", "redis://localhost:6379/0"),
    network_timeout: 5
  }

  # Set the number of threads for the Sidekiq server
  config.concurrency = 5

  # Configure queues to process
  config.queues = %w[default sms]
end

Sidekiq.configure_client do |config|
  config.redis = {
    url: ENV.fetch("REDIS_URL", "redis://localhost:6379/0"),
    network_timeout: 5
  }
end

# Configure Sidekiq logger
Sidekiq.logger.level = Logger::INFO if Rails.env.production?
