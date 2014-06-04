require 'rubygems'
require 'amqp'

msg_counter = 0
EM.run do
  AMQP.connect do |connection|
    AMQP::Channel.new(connection) do |channel|
      exchange = channel.topic('topic_routing')
      EM.add_periodic_timer(1) do
        payload = "msg #{msg_counter}"
        routing_key = "topic.msg." + (msg_counter.even? ? 'even' : 'odd')
        puts "publishing: #{payload}, routing key: #{routing_key}"
        exchange.publish(payload, routing_key: routing_key)
        msg_counter += 1
      end
    end
  end
end