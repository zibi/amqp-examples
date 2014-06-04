require 'rubygems'
require 'amqp'

msg_counter = 0
EM.run do
  AMQP.connect do |connection|
    AMQP::Channel.new(connection, prefetch: 5) do |channel|
      exchange = channel.fanout('load_balancing_fanout_exchange')
      channel.queue("ack.load_balancing_queue") do |queue|
        queue.bind(exchange).subscribe(ack: true) do |metadata, payload|
          puts "received: #{payload}"
          EM.add_timer(10) do
            puts "sending acknowledge for: #{payload}"
            metadata.ack
          end
        end
      end
    end
  end
end