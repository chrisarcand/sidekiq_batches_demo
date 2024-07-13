# Sidekiq Batches Demo

A minimal little playground to toy with the [Really Complex Workflows with Batches](https://github.com/sidekiq/sidekiq/wiki/Really-Complex-Workflows-with-Batches) example from the Sidekiq
documentation. 

As-is, you'll need a [Sidekiq Enterprise](https://sidekiq.org/products/enterprise.html) license to
use this example. Batching, however, is a [Sidekiq Pro] feature. Change the Gemfile as necessary and
remove the appropriate `require` in  the Rack configuration file (`sidekiq_web.ru`).

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
$ bundle exec ruby enqueue.rb
```
