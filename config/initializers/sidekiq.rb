ENV['REDIS_URL'] ||= 'redis://localhost:6379'

Sidekiq.configure_server do |config|
  config.redis = { url: "#{ENV['REDIS_URL']}/2", id: nil }
end

Sidekiq.configure_client do |config|
  config.redis = { url: "#{ENV['REDIS_URL']}/2", id: nil }
end
