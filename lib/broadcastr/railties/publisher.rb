module Broadcastr
  # :nodoc:
  # @private
  class PublisherRailtie < Rails::Railtie

    initializer "publisher_railtie.configure_rails_initialization" do |app|
      publish_setting = app.config.broadcastr.publish_amqp_events
      app_id = app.config.broadcastr.app_id
      broker_uri = app.config.broadcastr.broker_uri
      disable_publish = ->(p_setting) { (p_setting.blank? || !p_setting) && broker_uri.blank? }
      case publish_setting
      when disable_publish
        disable_local_publisher
      when :log, :logging, :logger
        log_local_publisher
      else
        boot_local_publisher(app_id)
      end
    end

    def disable_publishing
      Rails.logger.info "Setting 'broadcastr.publish_amqp_events' set to disabled - disabling publishing of events to AMQP instance'"
      disable_local_publisher
    end

    def boot_local_publisher(app_id)
      ::Broadcastr::Publisher.boot!(app_id)
    end

    def log_local_publisher
      Rails.logger.info "Setting 'broadcastr.publish_amqp_events' set to log - events will be reflected in the log"
      ::Broadcastr::Publisher.logging!
    end

    def disable_local_publisher
      ::Broadcastr::Publisher.disable!
    end
  end
end
