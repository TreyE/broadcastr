require "sneakers/worker"
require "sneakers/handlers/maxretry"

module Broadcastr
  module Amqp
    class WorkerSpecification
      attr_reader :kind
      attr_accessor :routing_key
      attr_writer :retry_count
      attr_writer :retry_delay
      attr_accessor :queue_name

      def initialize(args = {})
        args.each_pair do |k, v|
          self.send("#{k}=", v)
        end
      end

      def kind=(val)
        unless [:topic, :direct, "topic", "direct"].include?(val)
          raise ArgumentError, "kind must be either 'topic' or 'direct'"
        end
        @kind = val
      end

      def message_category=(val)
        unless [:events, :requests, "events", "requests"].include?(val)
          raise ArgumentError, "message_category must be either 'events' or 'requests'"
        end
        @message_category = val
      end

      def message_category
        @message_category || :events
      end

      def worker_timeout=(val)
        @worker_timeout_set = true
        @worker_timeout = val
      end

      def worker_timeout
        if @worker_timeout_set
          # Give the explicit string "nil" for subsitution,
          # since nil.to_s would incorrectly be ""
          @worker_timeout || "nil"
        else
          86400
        end
      end

      def message_category_for_exchange
        case message_category
        when "events", :events
          :events
        when "requests", :requests
          :requests
        else
          raise ArgumentError, "message_category must be either 'events' or 'requests'"
        end
      end

      def retry_count
        @retry_count || 5
      end

      def retry_delay
        @retry_delay || 5000
      end

      def exchange_kind
        case kind
        when "topic", :topic
          :topic
        when "direct", :direct
          :direct
        else
          raise ArgumentError, "kind must be either 'topic' or 'direct'"
        end
      end

      def exchange_name
        site_id = Rails.application.config.broadcastr.site
        env_name = Rails.application.config.broadcastr.environment_name
        "#{site_id}.#{env_name}.e.#{exchange_kind}.#{message_category_for_exchange.to_s}"
      end

      def full_queue_name
        site_id = Rails.application.config.broadcastr.site
        app_id = Rails.application.config.broadcastr.app_id 
        env_name = Rails.application.config.broadcastr.environment_name
        "#{site_id}.#{env_name}.q.#{app_id}.#{queue_name}"
      end

      def retry_exchange_name
        "#{full_queue_name}-retry"
      end

      def create_routing_key_string
        if routing_key.kind_of?(Array)
          key_list = routing_key.map do |rk|
            "\"#{rk}\""
          end.join(",")
          "[" + key_list + "]"
        else
          "\"#{routing_key}\""
        end
      end

      def execute_sneakers_config_against(kls)
        routing_key_string = create_routing_key_string
        kls.class_eval(<<-RUBYCODE)
          include ::Sneakers::Worker
          from_queue("#{full_queue_name}", {
               :ack => true,
               :prefetch => 1,
               :threads => 2,
               :durable => true,
               :exchange => "#{exchange_name}",
               :exchange_type => "#{exchange_kind}",
               :exchange_options => { :durable => true },
               :routing_key => #{routing_key_string},
               :handler => Sneakers::Handlers::Maxretry,
               :retry_timeout => #{retry_delay},
               :timeout_job_after => #{worker_timeout},
               :heartbeat => 5,
               :retry_max_times => #{retry_count},
               :arguments => {
                 :'x-dead-letter-exchange' => "#{retry_exchange_name}"
               }
          })
        RUBYCODE
      end
    end
  end
end
