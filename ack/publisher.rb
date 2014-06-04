require 'rubygems'
require 'amqp'

msg_counter = 0
EM.run do
  AMQP.connect do |connection|
    AMQP::Channel.new(connection) do |channel|
      exchange = channel.fanout('load_balancing_fanout_exchange')
      EM.add_periodic_timer(1) do
        payload = "msg #{msg_counter}"
        puts "publishing: #{payload}"
        exchange.publish(payload)
        msg_counter += 1
      end
    end
  end
end