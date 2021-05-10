require_relative "railties/amqp_configuration_options" if defined?(Rails)
require_relative "railties/amqp_worker_options" if defined?(Rails)
require_relative "railties/publisher" if defined?(Rails)
