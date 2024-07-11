```
$ bundle install
```

```
$ bundle exec sidekiq -r ./job_definitions.rb -C ./sidekiq.yml
```

```
$ bundle exec ruby enqueue.rb
```
