require_relative 'sidekiq'

Order = Struct.new('Order', :id)
order = Order.new(1)

overall = Sidekiq::Batch.new
overall.on(:complete, 'FulfillmentCallbacks#complete', 'oid' => order.id)
overall.on(:success, 'FulfillmentCallbacks#shipped', 'oid' => order.id)
overall.description = "Fulfillment for Order #{order.id}"
overall.jobs do
  StartWorkflow.perform_async(order.id)
end

puts "Enqueued fulfillment workflow for Order #{order.id}"
