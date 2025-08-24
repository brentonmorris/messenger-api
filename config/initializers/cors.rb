Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins ENV["CORS_ALLOWED_ORIGINS"]&.split(",") || "*"

    ENV.fetch("CORS_ALLOWED_RESOURCES", "*").split(",").each do |resource_path|
      resource resource_path.strip,
        headers: :any,
        methods: [:get, :post, :put, :patch, :delete, :options],
        expose: [:Authorization]
    end
  end
end
