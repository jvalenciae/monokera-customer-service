require 'rails_helper'
require 'bunny'
# require_relative 'rabbitmq_publisher'

RSpec.describe OrderCreatedSubscriber do
  let(:customer) { create(:customer, orders_count: 5) }
  let(:valid_payload) do
    {
      event_type: "order_created",
      data: {
        customer_id: customer.id,
        order_id: 123,
        product_name: "Book",
        quantity: 2,
        price: 49.99
      }
    }.to_json
  end

  let(:connection) { instance_double(Bunny::Session) }
  let(:channel) { instance_double(Bunny::Channel) }
  let(:exchange) { instance_double(Bunny::Exchange) }
  let(:queue) { instance_double(Bunny::Queue) }

  before(:each) do
    allow(RabbitMqConnection.instance).to receive(:channel).and_return(channel)

    allow(Bunny).to receive(:new).and_return(connection)
    allow(connection).to receive(:start)
    allow(connection).to receive(:create_channel).and_return(channel)

    allow(channel).to receive(:default_exchange).and_return(exchange)
    allow(channel).to receive(:topic).and_return(exchange)
    allow(channel).to receive(:prefetch).with(1).and_return(channel)

    allow(channel).to receive(:queue).with('orders.events', durable: true).and_return(queue)

    allow(queue).to receive(:bind).with(exchange, routing_key: "order.created")
  end

  describe '#initialize' do
    it 'initializes with RabbitMQ connection' do
      expect(RabbitMqConnection.instance).to receive(:channel)
      described_class.new
    end
  end

  describe '#start' do
    it 'sets up the queue and subscribes to events' do
      subscriber = described_class.new

      expect(subscriber).to receive(:setup_queue)
      expect(subscriber).to receive(:subscribe_to_events)

      subscriber.start
    end
  end

  describe '#stop' do
    it 'closes the channel and logs the stop' do
      allow(channel).to receive(:close)

      subscriber = described_class.new
      subscriber.stop

      expect(channel).to have_received(:close)
    end
  end

  describe 'constants' do
    it 'defines correct queue name and routing key' do
      expect(described_class::QUEUE_NAME).to eq("orders.events")
      expect(described_class::ROUTING_KEY).to eq("order.created")
    end
  end
end
