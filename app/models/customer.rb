class Customer < ApplicationRecord
  validates :customer_name, :address, presence: true
  validates :orders_count, numericality: { greater_than_or_equal_to: 0 }

  def self.increment_order_count(customer_id)
    UpdateOrderCountService.new(customer_id).call
  end
end
