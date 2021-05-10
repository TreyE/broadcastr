require "spec_helper"
require "broadcastr"

describe Broadcastr::Amqp::WorkerSpecification, "given a routing key array" do
  let(:routing_key) { ["*.events.#", "*.application.gluedb.#"] }

  subject { described_class.new(:routing_key => routing_key) }

  it "has the correct routing key string" do
    expect(subject.create_routing_key_string).to eq("[\"*.events.#\",\"*.application.gluedb.#\"]")
  end
end

describe Broadcastr::Amqp::WorkerSpecification, "given a single routing key" do
  let(:routing_key) { "*.events.#" }

  subject { described_class.new(:routing_key => routing_key) }

  it "has the correct routing key string" do
    expect(subject.create_routing_key_string).to eq("\"*.events.#\"")
  end
end
