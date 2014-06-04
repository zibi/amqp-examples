require 'rubygems'
require 'amqp'

EM.run do
  AMQP.connect do |connection|
    AMQP::Channel.new(connection) do |channel|
      dlq_exchange = channel.fanout('test_dlq_exchange')
      channel.queue("") do |queue|
        queue.bind(dlq_exchange).subscribe do |metadata, payload|
          puts "received: #{payload}"
        end
      end
    end
  end
end