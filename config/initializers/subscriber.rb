require "./app/services/order_created_subscriber"

if Rails.env.development?
  Thread.new do
    puts "[OrderCreatedSubscriber] Starting subscriber..."

    begin
      subscriber = OrderCreatedSubscriber.new
      subscriber.start
    rescue => e
      puts "[OrderCreatedSubscriber] Failed to start: #{e.message}"
    end
  end
end
