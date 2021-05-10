module Broadcastr
  class ConfigurationSettings
    attr_accessor :app_id
    attr_accessor :broker_uri
    attr_accessor :site
    attr_accessor :environment_name
    attr_accessor :publish_amqp_events
  end
end

module Rails
  class Application
    class Configuration < Rails::Engine::Configuration
      # @return [Acapi::ConfigurationSettings]
      def broadcastr
        @broadcastr ||= ::Broadcastr::ConfigurationSettings.new
      end
    end
  end
end
