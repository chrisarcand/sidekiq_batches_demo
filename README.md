# Sidekiq Batches Demo

A minimal little playground to toy with the [Really Complex Workflows with Batches](https://github.com/sidekiq/sidekiq/wiki/Really-Complex-Workflows-with-Batches) example from the Sidekiq
documentation. 

As-is, you'll need a [Sidekiq Enterprise](https://sidekiq.org/products/enterprise.html) license to
use this example. Batching, however, only requires [Sidekiq Pro](https://sidekiq.org/products/pro.html) feature. Change the Gemfile as necessary and
remove the appropriate `require` in  the Rack configuration file (`sidekiq_web.ru`), if you'd like
to just use Pro.

## Usage

Install dependencies:
```
$ bundle install
```

Run Sidekiq server process:

```
$ bundle exec sidekiq -r ./job_definitions.rb -C ./sidekiq.yml
```

Run the Sidekiq Web UI:

```
$ bundle exec rackup sidekiq_web.ru
```

Enqueue the example:

```
$ bundle exec ruby ./enqueue.rb
```

Open a [pry](https://github.com/pry/pry) developer console with all dependencies required:

```
$ bundle exec pry -r ./sidekiq.rb

[1] pry(main)> Sidekiq::Queue.all
2024-07-14T15:03:29.240Z pid=9390 tid=6x2 INFO: Sidekiq 7.3.0 connecting to Redis with options {:size=>10, :pool_name=>"internal", :url=>"redis://localhost:6379/0"}
=> [#<Sidekiq::Queue:0x00000001051a3e88 @name="default", @rname="queue:default">]
```
