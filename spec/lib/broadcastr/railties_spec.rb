require 'spec_helper'
require 'broadcastr'

shared_examples "a broadcastr amqp configuration" do |args|
  args.each do |arg|
    it "should allow configuration of :#{arg}" do
      expect(Rails.application.config.broadcastr).to respond_to(arg)
      expect(Rails.application.config.broadcastr).to respond_to("#{arg}=".to_sym)
    end
  end
end

describe "with the proper rails configuration options" do
  it_behaves_like "a broadcastr amqp configuration", [:environment_name, :app_id, :site]
end
