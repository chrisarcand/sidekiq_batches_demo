require 'sidekiq'
require 'sidekiq-ent'

class StartWorkflow
  include Sidekiq::Job

  def perform(order_id)
    batch.jobs do
      step1 = Sidekiq::Batch.new
      step1.on(:success, 'FulfillmentCallbacks#step1_done', 'oid' => order_id)
      step1.jobs do
        A.perform_async(order_id)
      end
    end
  end
end

class FulfillmentCallbacks
  def step1_done(status, options)
    oid = options['oid']
    overall = Sidekiq::Batch.new(status.parent_bid)
    overall.jobs do
      step2 = Sidekiq::Batch.new
      step2.on(:success, 'FulfillmentCallbacks#step2_done', 'oid' => oid)
      step2.jobs do
        B.perform_async
        C.perform_async
        D.perform_async
        E.perform_async
        F.perform_async
      end
    end
  end

  def step2_done(status, options)
    oid = options['oid']
    overall = Sidekiq::Batch.new(status.parent_bid)
    overall.jobs do
      step3 = Sidekiq::Batch.new
      step3.on(:success, 'FulfillmentCallbacks#step3_done', 'oid' => oid)
      step3.jobs do
        G.perform_async(oid)
      end
    end
  end

  def step3_done(status, options)
    oid = options['oid']
    overall = Sidekiq::Batch.new(status.parent_bid)
    overall.jobs do
      step4 = Sidekiq::Batch.new
      step4.on(:success, 'FulfillmentCallbacks#step4_done', 'oid' => oid)
      step4.jobs do
        H.perform_async(oid)
        I.perform_async(oid)
      end
    end
  end

  def step4_done(status, options)
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
    puts "Order #{oid} has shipped!"
  end

  def complete(status, options)
    oid = options['oid']
    puts "Order #{oid} COMPLETE (not successful, necessarily)"
  end
end

class A
  include Sidekiq::Job

  def perform(order_id)
    puts "Performing job A for order #{order_id}"
  end
end

class B
  include Sidekiq::Job

  def perform
    puts "Performing job B"
  end
end

class C
  include Sidekiq::Job

  def perform
    puts "Performing job C"
  end
end

class D
  include Sidekiq::Job

  def perform
    puts "Performing job D"
  end
end

class E
  include Sidekiq::Job

  def perform
    puts "Performing job E"
  end
end

class F
  include Sidekiq::Job

  def perform
    puts "Performing job F"
  end
end

class G
  include Sidekiq::Job

  def perform(oid)
    puts "Performing job G for order #{oid}"
  end
end

class H
  include Sidekiq::Job

  def perform(oid)
    puts "Performing job H for order #{oid}"
  end
end

class I
  include Sidekiq::Job

  def perform(oid)
    puts "Performing job I for order #{oid}"
  end
end

class J
  include Sidekiq::Job

  def perform(oid)
    puts "Performing job J for order #{oid}"
  end
end

class K
  include Sidekiq::Job

  def perform(oid)
    puts "Performing job K for order #{oid}"
  end
end

class L
  include Sidekiq::Job

  def perform(oid)
    puts "Performing job L for order #{oid}"
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
  end
end
