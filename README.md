# Broadcastr

Simplified AMQP publish/subscribe with sensible defaults in your rails applications.

Sneakers has too many options and you don't care about most of them.  Wouldn't you like some sensible defaults?

**NOTE: The following functions are still missing and need to be brought in:**
1. **Documentation for publishing**
2. **yelling at you if you don't configure all the required settings**
3. **where Rubocop?** 

## What does this give me beyond basic Sneakers?

This gem adds a few features on top of the base Sneakers gem:
1. Retry and error handling by default.
2. Minimal dependencies.  What ruby version are you using?  Who cares?
2. A sensible, default topology that lets consumers decide what messages they want.
3. Easily configure the number of clients you want by type in a single place.
4. Host all workers under a single process tree with shared memory, start it with a single line of code, and never mess with foreman again!
5. Most importantly: provides an easy way to broadcast events from within a working client.

### Broadcasting Confirmed Events While You Work

At any point in the work method of your subscriber, you may call `with_confirmed_channel`.  This will yield an AMQP channel with which to send events that will be automatically closed and confirmed at the end of the block:
```ruby
with_confirmed_channel do |channel|
 channel.default.publish("my message", {:routing_key => "a queue name"})
end
```

## General Configuration

All configuration, from general setup to registering your listeners, is performed using the rails standard configuration objects:
```ruby
Rails.application.configure do
  config.broadcastr.app_id= "notifier"
  config.broadcastr.site = "dc0"
  config.broadcastr.environment_name = "preprod"
  config.broadcastr.broker_uri = "amqp://guest:guest@localhost:5761/"
end
```

## Creating Event Subscribers

An event subscriber is just a class that is registered in the configuration and includes two important methods.

It doesn't inherit or mix anything in until booted and allows normal testing without knowing anything about AMQP.

```ruby
class MyWorkerClass

  # This is the first required method.  It needs to return a
  # WorkerSpecification.
  def self.worker_specification
    Acapi::Amqp::WorkerSpecification.new(
      # A friendly name for your queue.  Not super important as all the
      # setup will be configured behind the scenes, only really matters that
      # it is unique.
      :queue_name => "my_worker_class_queue_name",
      # Kind is either 'direct' (for exact matches) or
      # 'topic' (for wildcard or pattern matches)
      :kind => :direct,
      # The routing key(s) of the event you care about.
      # Can take a single or multiple keys, and if the 'kind' is topic,
      # can take wildcards/patterns as well.
      :routing_key => "info.events.worker.some_event"
    )
  end

  # This is the second required method, it needs to do the work of your
  # subscriber and return the same set of values as a Sneakers worker would -
  # i.e. call ack!, requeue!, or reject!
  # If you throw an exception, an error will be signalled automatically
  # for retry.
  def work_with_params(body, delivery_info, properties)
    # We'll do our work here
  end

end
```

You register your subscribers using the rails configuration:
```ruby
Rails.application.configure do
  # General Configuration as above...

  # It takes the name of your worker class, as well as an optional number of
  # Workers you would like to run (default is 1)
  config.broadcastr.add_amqp_worker("MyWorkerClass")
  config.broadcastr.add_amqp_worker("MyOtherWorkerClass", 3)
end
```

## Running Your Workers

Once you've configured everything, simply add a script that calls:
```
Broadcastr::AmqpEventWorker.run
```
And that's it!

The worker host will kick off and manage the number of subscribers you configured.
