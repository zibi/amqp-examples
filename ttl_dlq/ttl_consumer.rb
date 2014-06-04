require 'rubygems'
require 'amqp'

EM.run do
  AMQP.connect do |connection|
    AMQP::Channel.new(connection) do |channel|
      dlq_exchange = channel.fanout('test_dlq_exchange')
      exchange = channel.fanout('test_fanout_exchange')
      channel.queue("test_dlq_queue", arguments: {
        "x-dead-letter-exchange" => 'test_dlq_exchange',
         "x-message-ttl" => 5000
      }) do |queue|
        queue.bind(exchange).subscribe do |metadata, payload|
          puts "received: #{payload}"
        end
      end
    end
  end
end