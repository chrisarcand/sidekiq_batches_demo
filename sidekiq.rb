require 'sidekiq'
require 'sidekiq-ent'
require 'dotenv/load'
require 'ostruct'
require_relative 'job_definitions'

Sidekiq.configure_client do |config|
  config.redis = { url: ENV['REDIS_URL'] }
end

