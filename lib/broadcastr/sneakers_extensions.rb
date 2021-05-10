require "sneakers"

module Broadcastr
  module SneakersExtensions
    module QueueExtensions
      def connection
        @bunny
      end
    end
    module WorkerExtensions
      def connection
        queue.connection
      end

      def with_confirmed_channel
        chan = connection.create_channel
        begin
          chan.confirm_select
          yield chan
          chan.wait_for_confirms
        ensure
          chan.close
        end
      end
    end
  end
end

Sneakers::Queue.class_eval do
  include Broadcastr::SneakersExtensions::QueueExtensions
end

Sneakers::Worker.module_eval do
  include Broadcastr::SneakersExtensions::WorkerExtensions
end
