require "spec_helper"
require "broadcastr"

class BroadcastrConfigurationSlugApp < Rails::Application
  config.eager_load = false
end

describe Broadcastr, "missing required configuration values" do
  it "raises an error" do
    app = BroadcastrConfigurationSlugApp.instance
    initializer = app.initializers.detect do |initer|
      initer.name == "broadcastr.amqp_configuration_railtie.validate_amqp_configuration"
    end
    expect { initializer.run app }.to raise_error(::Broadcastr::Errors::MissingSettingsError)
  end
end
