require 'rubygems'
require 'amqp'

msg_id = 1
request_types = ['pdf', 'ppt'].cycle
client_id = nil
EM.run do
  AMQP.connect do |connection|
    AMQP::Channel.new(connection) do |channel|
      requests_exchange = channel.topic('task_requests')

      results_exchange = channel.direct('task_results')
      channel.queue("", auto_delete: true, exclusive: true) do |queue|
        client_id = queue.name
        queue.bind(results_exchange, routing_key: client_id).subscribe do |metadata, payload|
          puts "received results for request: #{metadata.correlation_id}"
        end
      end

      EM.add_periodic_timer(1) do |variable|
        payload = "msg #{msg_id}"
        routing_key = "request.#{request_types.next}"
        puts "publishing: #{payload}, routing key: #{routing_key}"
        requests_exchange.publish(payload,
          routing_key: routing_key,
          message_id: msg_id,
          reply_to: client_id)
        msg_id += 1
      end
    end
  end
end