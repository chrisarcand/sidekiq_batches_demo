require 'sidekiq'
require 'sidekiq-ent'

class StartWorkflow
  include Sidekiq::Job

  def perform(order_id)
    batch.jobs do
      step1 = Sidekiq::Batch.new
      step1.on(:complete, 'FulfillmentCallbacks#step1_complete', 'oid' => order_id)
      step1.on(:success,  'FulfillmentCallbacks#step1_success',  'oid' => order_id)
      step1.jobs do
        A.perform_async(order_id)
      end
    end
  end
end

class FulfillmentCallbacks
  def step1_complete(status, options)
    Sidekiq.logger.info "Step 1 complete"
  end

  def step1_success(status, options)
    Sidekiq.logger.info "Step 1 successful! Enqueuing next step..."
    oid = options['oid']
    overall = Sidekiq::Batch.new(status.parent_bid)
    overall.jobs do
      step2 = Sidekiq::Batch.new
      step2.on(:complete, 'FulfillmentCallbacks#step2_complete', 'oid' => oid)
      step2.on(:success,  'FulfillmentCallbacks#step2_success',  'oid' => oid)
      step2.jobs do
        B.perform_async
        C.perform_async
        D.perform_async
        E.perform_async
        F.perform_async
      end
    end
  end

  def step2_complete(status, options)
    Sidekiq.logger.info "Step 2 complete"
  end

  def step2_success(status, options)
    Sidekiq.logger.info "Step 2 successful! Enqueuing next step..."
    oid = options['oid']
    overall = Sidekiq::Batch.new(status.parent_bid)
    overall.jobs do
      step3 = Sidekiq::Batch.new
      step3.on(:complete, 'FulfillmentCallbacks#step2_complete', 'oid' => oid)
      step3.on(:success,  'FulfillmentCallbacks#step3_success',  'oid' => oid)
      step3.jobs do
        G.perform_async(oid)
      end
    end
  end

  def step3_complete(status, options)
    Sidekiq.logger.info "Step 3 complete"
  end

  def step3_success(status, options)
    Sidekiq.logger.info "Step 3 successful! Enqueuing next step..."
    oid = options['oid']
    overall = Sidekiq::Batch.new(status.parent_bid)
    overall.jobs do
      step4 = Sidekiq::Batch.new
      step4.on(:complete, 'FulfillmentCallbacks#step2_complete', 'oid' => oid)
      step4.on(:success,  'FulfillmentCallbacks#step4_success',  'oid' => oid)
      step4.jobs do
        H.perform_async(oid)
        I.perform_async(oid)
      end
    end
  end

  def step4_complete(status, options)
    Sidekiq.logger.info "Step 4 complete"
  end

  def step4_success(status, options)
    Sidekiq.logger.info "Step 4 successful! Enqueuing next step..."
    oid = options['oid']
    overall = Sidekiq::Batch.new(status.parent_bid)
    overall.jobs do
      J.perform_async(oid)
      K.perform_async(oid)
      L.perform_async(oid)
    end
  end

  def shipped(status, options)
    oid = options['oid']
    puts "Order #{oid} was successfully shipped!"
  end

  def complete(status, options)
    oid = options['oid']
    puts "Order #{oid} complete (may or may not contain errors)"
  end
end

SLEEP_TIME = 2..5

class A
  include Sidekiq::Job

  def perform(order_id)
    puts "Performing job A for order #{order_id}"
    sleep(rand(SLEEP_TIME))
  end
end

class B
  include Sidekiq::Job

  def perform
    puts "Performing job B"
    sleep(rand(SLEEP_TIME))
  end
end

class C
  include Sidekiq::Job

  def perform
    puts "Performing job C"
    sleep(rand(SLEEP_TIME))
  end
end

class D
  include Sidekiq::Job

  def perform
    puts "Performing job D"
    sleep(rand(SLEEP_TIME))
  end
end

class E
  include Sidekiq::Job

  def perform
    puts "Performing job E"
    sleep(rand(SLEEP_TIME))
  end
end

class F
  include Sidekiq::Job

  def perform
    puts "Performing job F"
    sleep(rand(SLEEP_TIME))
  end
end

class G
  include Sidekiq::Job

  def perform(oid)
    puts "Performing job G for order #{oid}"
    sleep(rand(SLEEP_TIME))
  end
end

class H
  include Sidekiq::Job

  def perform(oid)
    puts "Performing job H for order #{oid}"
    sleep(rand(SLEEP_TIME))
  end
end

class I
  include Sidekiq::Job

  def perform(oid)
    puts "Performing job I for order #{oid}"
    sleep(rand(SLEEP_TIME))
  end
end

class J
  include Sidekiq::Job

  def perform(oid)
    puts "Performing job J for order #{oid}"
    sleep(rand(SLEEP_TIME))
  end
end

class K
  include Sidekiq::Job

  def perform(oid)
    puts "Performing job K for order #{oid}"
    sleep(rand(SLEEP_TIME))
  end
end

class L
  include Sidekiq::Job

  def perform(oid)
    puts "Performing job L for order #{oid}"
    sleep(rand(SLEEP_TIME))
    if bid
      batch.jobs do
        M.perform_async(oid)
      end
    end
  end
end

class M
  include Sidekiq::Job

  def perform(oid)
    puts "Performing job M for order #{oid}"
    sleep(rand(SLEEP_TIME))
  end
end
