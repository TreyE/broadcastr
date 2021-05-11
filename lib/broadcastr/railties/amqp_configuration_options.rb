module Broadcastr
  class ConfigurationSettings
    attr_accessor :app_id
    attr_accessor :broker_uri
    attr_accessor :site
    attr_accessor :environment_name
    attr_accessor :publish_amqp_events
  end

  class AmqpConfigurationRailtie < Rails::Railtie
    initializer "broadcastr.amqp_configuration_railtie.validate_amqp_configuration" do |app|
      app_id = app.config.broadcastr.app_id
      site = app.config.broadcastr.site
      environment_name = app.config.broadcastr.environment_name
      if [app_id, site, environment_name].any?(&:blank?)
        exception = ::Broadcastr::Errors::MissingSettingsError.new({
          app_id: app_id,
          site: site,
          environment_name: environment_name
        })
        raise exception
      end
    end
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
