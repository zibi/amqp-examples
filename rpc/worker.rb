require 'rubygems'
require 'amqp'

request_type = ARGV.last
EM.run do
  AMQP.connect do |connection|
    AMQP::Channel.new(connection) do |channel|
      requests_exchange = channel.topic('task_requests')
      results_exchange = channel.direct('task_results')

      channel.queue(request_type) do |queue|
        queue.bind(requests_exchange, routing_key: "request.#{request_type}").subscribe do |metadata, payload|
          puts "received request: #{payload}, routing key: #{metadata.routing_key}"
          results_exchange.publish("result for msg #{metadata.message_id}", routing_key: metadata.reply_to, correlation_id: metadata.message_id)
        end
      end
    end
  end
end