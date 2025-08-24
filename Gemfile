source "https://rubygems.org"

gem "bootsnap", require: false
gem "devise"
gem "devise-jwt"
gem "dotenv-rails", groups: [:development, :test]
gem "jsonapi-serializer"
gem "kamal", require: false
gem "mongoid", "~> 9.0"
gem "puma", ">= 5.0"
gem "rack-cors", "~> 3.0"
gem "rails", "~> 8.0.2", ">= 8.0.2.1"
gem "redis", ">= 4.0.1"
gem "sidekiq"
gem "thruster", require: false
gem "twilio-ruby", "~> 7.7"
gem "tzinfo-data", platforms: %i[windows jruby]

group :development do
  gem "solargraph"
  gem "erb-formatter", "~> 0.7.3"
end

group :development, :test do
  gem "brakeman", require: false
  gem "debug", platforms: %i[mri windows], require: "debug/prelude"
  gem "rubocop", require: false
  gem "standard", ">= 1.35.1", require: false
end

gem "foreman", "~> 0.90.0", group: :development
