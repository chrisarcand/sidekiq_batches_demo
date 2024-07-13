require 'sidekiq'
require 'sidekiq-ent'

Sidekiq.configure_server do |config|
  config.logger.level = Logger::DEBUG
end

class StartWorkflow
  include Sidekiq::Job

  def perform(order_id)
    batch.jobs do
      step1 = Sidekiq::Batch.new
      step1.description = "Nested batch for Step 1 - Job A"
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
    log_callback!
  end

  def step1_success(status, options)
    log_callback!

    oid = options['oid']
    overall = Sidekiq::Batch.new(status.parent_bid)
    overall.jobs do
      step2 = Sidekiq::Batch.new
      step2.description = "Nested batch for Step 2 - Jobs B, C, D, E, & F"
      step2.on(:complete, 'FulfillmentCallbacks#step2_complete', 'oid' => oid)
      step2.on(:success,  'FulfillmentCallbacks#step2_success',  'oid' => oid)
      step2.jobs do
        B.perform_async(oid)
        C.perform_async(oid)
        D.perform_async(oid)
        E.perform_async(oid)
        F.perform_async(oid)
      end
    end
  end

  def step2_complete(status, options)
    log_callback!
  end

  def step2_success(status, options)
    log_callback!

    oid = options['oid']
    overall = Sidekiq::Batch.new(status.parent_bid)
    overall.jobs do
      step3 = Sidekiq::Batch.new
      step3.description = "Nested batch for Step 3 - Job G"
      step3.on(:complete, 'FulfillmentCallbacks#step2_complete', 'oid' => oid)
      step3.on(:success,  'FulfillmentCallbacks#step3_success',  'oid' => oid)
      step3.jobs do
        G.perform_async(oid)
      end
    end
  end

  def step3_complete(status, options)
    log_callback!
  end

  def step3_success(status, options)
    log_callback!

    oid = options['oid']
    overall = Sidekiq::Batch.new(status.parent_bid)
    overall.jobs do
      step4 = Sidekiq::Batch.new
      step4.description = "Nested batch for Step 4 - Jobs H & I"
      step4.on(:complete, 'FulfillmentCallbacks#step2_complete', 'oid' => oid)
      step4.on(:success,  'FulfillmentCallbacks#step4_success',  'oid' => oid)
      step4.jobs do
        H.perform_async(oid)
        I.perform_async(oid)
      end
    end
  end

  def step4_complete(status, options)
    log_callback!
  end

  def step4_success(status, options)
    log_callback!

    oid = options['oid']
    overall = Sidekiq::Batch.new(status.parent_bid)
    overall.jobs do
      J.perform_async(oid)
      K.perform_async(oid)
      L.perform_async(oid)
    end
  end

  def shipped(status, options)
    log_callback!

    oid = options['oid']
    puts "Order #{oid} was successfully shipped!"
  end

  def complete(status, options)
    log_callback!

    oid = options['oid']
    puts "Order #{oid} complete (may or may not contain errors)"
  end

  private

  def log_callback!
    caller_info = caller(1..1).first
    method_name = caller_info[/`([^']*)'/, 1]
    Sidekiq.logger.debug "CALLBACK EXECUTED: #{self.class.name}##{method_name}"
  end
end

SLEEP_TIME = 2..10

('A'..'M').each do |letter|
  next if letter == 'L'

  klass = Class.new do
    include Sidekiq::Job

    define_method :perform do |oid|
      logger.debug "Performing job #{letter} for order #{oid}"
      sleep(rand(SLEEP_TIME))
    end
  end

  Object.const_set(letter, klass)
end

class L
  include Sidekiq::Job

  def perform(oid)
    logger.debug "Performing job L for order #{oid}"
    sleep(rand(SLEEP_TIME))
    if bid
      batch.jobs do
        M.perform_async(oid)
      end
    end
  end
end

