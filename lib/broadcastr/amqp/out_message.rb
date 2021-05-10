require 'securerandom'

module Broadcastr
  module Amqp
    class OutMessage
      AMQP_MESSAGE_PROPERTIES = [:correlation_id, :reply_to, :user_id, :content_type, :timestamp]

      def initialize(a_id, e_name, payload, headers = {})
        @app_id = a_id
        @event_name = e_name
        @payload = payload
        @headers = headers
      end

      def extract_event_properties(message_data)
        other_amqp_props = {}
        AMQP_MESSAGE_PROPERTIES.each do |prop_sym|
          if message_data.has_key?(prop_sym)
            prop_val = message_data.delete(prop_sym)
            other_amqp_props[prop_sym] = prop_val
          end
          if message_data.has_key?(prop_sym.to_s)
            prop_val = message_data.delete(prop_sym.to_s)
            other_amqp_props[prop_sym] = prop_val
          end
        end
        if (!other_amqp_props.has_key?(:correlation_id)) && (!other_amqp_props.has_key?("correlation_id"))
          other_amqp_props[:correlation_id] = SecureRandom.uuid.gsub("-","")
        end
        other_amqp_props
      end

      def to_message_properties
        message_data = @headers.dup
        body_data = @payload
        if (!message_data.has_key?(:workflow_id)) && (!message_data.has_key?("workflow_id"))
          message_data[:workflow_id] = SecureRandom.uuid.gsub("-","")
        end
        body_data = body_data.nil? ? "" : body_data.to_s
        @end_time ||= Time.now
        message_props = {
          :routing_key => @event_name,
          :app_id => @app_id,
          :timestamp => @end_time.to_i,
          :headers => ({
            :submitted_timestamp => @end_time
          }).merge(message_data)
        }.merge(extract_event_properties(message_data))
        [body_data, message_props]
      end
    end
  end
end
