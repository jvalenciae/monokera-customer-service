require "json"
require "./lib/rabbit_mq_connection"

class OrderCreatedSubscriber
  QUEUE_NAME = "orders.events"
  ROUTING_KEY = "order.created"

  def initialize
    @connection = RabbitMqConnection.instance
    @channel = @connection.channel
    @queue = nil
  end

  def start
    setup_queue
    subscribe_to_events
  end

  def stop
    @channel&.close
  end

  private

  def setup_queue
    exchange = @channel.topic("orders", durable: true)

    @queue = @channel.queue(QUEUE_NAME, durable: true)

    @queue.bind(exchange, routing_key: ROUTING_KEY)
  end

  def subscribe_to_events
    @queue.subscribe(manual_ack: true) do |delivery_info, _properties, payload|
      begin
        event_data = parse_payload(payload)

        customer_id = event_data.dig("data", "customer_id")

        UpdateOrderCountService.new(customer_id).call if customer_id

        @channel.ack(delivery_info.delivery_tag)

      rescue JSON::ParserError => e
        @channel.ack(delivery_info.delivery_tag)
      rescue => e
        @channel.nack(delivery_info.delivery_tag, false, true)
      end
    end
  end

  def parse_payload(payload)
    JSON.parse(payload)
  end
end
