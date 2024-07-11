require 'sidekiq'
require 'sidekiq-ent'
require 'dotenv/load'
require 'ostruct'
require_relative 'job_definitions'

Sidekiq.configure_client do |config|
  config.redis = { url: ENV['REDIS_URL'] }
end

order = OpenStruct.new(id: 1)
overall = Sidekiq::Batch.new
overall.on(:complete, 'FulfillmentCallbacks#complete', 'oid' => order.id)
overall.on(:success, 'FulfillmentCallbacks#shipped', 'oid' => order.id)
overall.description = "Fulfillment for Order #{order.id}"
overall.jobs do
  StartWorkflow.perform_async(order.id)
end

puts "Enqueued fulfillment workflow for Order #{order.id}"
