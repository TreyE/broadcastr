require "spec_helper"
require "broadcastr"

class BroadcastPublisherSlugApp < Rails::Application
  config.eager_load = false
end

describe Broadcastr::Publisher do
  it "allows event publishing" do
    app = BroadcastPublisherSlugApp.instance
    initializer = app.initializers.detect do |initer|
        initer.name == "publisher_railtie.configure_rails_initialization"
      end
    initializer.run app
    Broadcastr::Publisher.publish("event", "")
  end
end
