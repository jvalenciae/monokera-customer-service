require "singleton"
require "bunny"

class RabbitMqConnection
  include Singleton

  def initialize
    @connection = nil
    @channel = nil
  end

  def connection
    @connection ||= create_connection
  end

  def channel
    @channel ||= create_channel
  end

  def close
    @channel&.close
    @connection&.close
    @channel = nil
    @connection = nil
  end

  private

  def create_connection
    Bunny.new(
      host: ENV.fetch("RABBITMQ_HOST", "localhost"),
      port: ENV.fetch("RABBITMQ_PORT", 5672),
      user: ENV.fetch("RABBITMQ_USER", "guest"),
      password: ENV.fetch("RABBITMQ_PASSWORD", "guest"),
      vhost: ENV.fetch("RABBITMQ_VHOST", "/")
    ).tap(&:start)
  end

  def create_channel
    connection.create_channel.tap do |ch|
      ch.prefetch(1)
    end
  end
end
