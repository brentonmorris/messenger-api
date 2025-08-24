unless Rails.env.production?
  test_user = User.find_or_create_by(email: "balint@example.com") do |user|
    user.password = ENV["BALINT_PASSWORD"]
    user.password_confirmation = ENV["BALINT_PASSWORD"]
  end
  puts "Created test user: #{test_user.email}" if test_user.persisted?

  test_user = User.find_or_create_by(email: "nora@example.com") do |user|
    user.password = ENV["NORA_PASSWORD"]
    user.password_confirmation = ENV["NORA_PASSWORD"]
  end
  puts "Created test user: #{test_user.email}" if test_user.persisted?

  test_user = User.find_or_create_by(email: "reka@example.com") do |user|
    user.password = ENV["REKA_PASSWORD"]
    user.password_confirmation = ENV["REKA_PASSWORD"]
  end
  puts "Created test user: #{test_user.email}" if test_user.persisted?
end
