require 'rubygems'
require 'amqp'

msg_counter = 0
EM.run do
  AMQP.connect do |connection|
    AMQP::Channel.new(connection, prefetch: 5) do |channel|
      exchange = channel.topic('topic_routing')
      channel.queue("", auto_delete: true, exclusive: true) do |queue|
        queue.bind(exchange, routing_key: 'topic.msg.odd').subscribe do |metadata, payload|
          puts "received: #{payload}, routing key: #{metadata.routing_key}"
        end
      end
    end
  end
end