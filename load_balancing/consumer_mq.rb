require 'rubygems'
require 'amqp'

msg_counter = 0
EM.run do
  AMQP.connect do |connection|
    AMQP::Channel.new(connection) do |channel|
      exchange = channel.fanout('load_balancing_fanout_exchange')
      channel.queue("", auto_delete: true, exclusive: true) do |queue|
        queue.bind(exchange).subscribe do |metadata, payload|
          puts "received: #{payload}"
        end
      end
    end
  end
end