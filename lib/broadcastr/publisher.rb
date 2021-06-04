require 'bunny'

module Broadcastr
  class Publisher
    class DoNothingPublisher
      def publish(*args)
      end

      def reconnect!
      end

      def disconnect!
      end
    end

    class LoggingPublisher 
      def publish(*args)
        Rails.logger.info "Acapi::Publisher- Logging subscribed event:\n#{args.inspect}"
      end

      def reconnect!
      end

      def disconnect!
      end
    end

    def self.instance
      @@instance
    end

    def self.logging!
      if defined?(@@instance) && !@instance.nil?
        @@instance.disconnect!
      end
      @@instance = LoggingPublisher.new
    end

    def self.disable!
      if defined?(@@instance) && !@instance.nil?
        @@instance.disconnect!
      end
      @@instance = DoNothingPublisher.new
    end

    def self.boot!(app_id)
      @@instance = self.new(app_id)
      Broadcastr::Amqp::MessagingExchangeTopology.ensure_topology_exists(Rails.application.config.broadcastr.broker_uri)
    end

    def self.publish(event, payload, headers = {})
      @@instance.publish(event, payload, headers)
    end

    def initialize(app_id)
      @app_id = app_id
      @connection = nil
    end

    def publish(event, payload, headers = {})
      open_connection_if_needed
      msg = Broadcastr::Amqp::OutMessage.new(@app_id, event, payload, headers = {})
      chan = @connection.create_channel
      begin
        chan.confirm_select
        exchange = chan.fanout(event_exchange_name, {:durable => true})
        exchange.publish(*msg.to_message_properties)
        chan.wait_for_confirms
      ensure
        chan.close
      end
    end

    def event_exchange_name
      site = Rails.application.config.broadcastr.site
      env_name = Rails.application.config.broadcastr.environment_name
      "#{site}.#{env_name}.e.fanout.events"
    end

    def open_connection_if_needed
      unless @connection && @connection.connected?
        @connection = Bunny.new(Rails.application.config.broadcastr.broker_uri, :heartbeat => 5)
        @connection.start
      end
    end

    def reconnect!
      disconnect!
      open_connection_if_needed
    end

    def disconnect!
      if @connection && @connection.connected?
        begin
          @connection.close
        rescue Timeout::Error
        end
        @connection = nil
      end
    end

    def self.reconnect!
      instance.reconnect!
    end
    end
  end
