class UpdateOrderCountService
  def initialize(customer_id)
    @customer_id = customer_id
  end

  def call
    customer = Customer.find(@customer_id)
    customer.increment!(:orders_count)
    customer
  rescue ActiveRecord::RecordNotFound
    raise ArgumentError, "Customer with ID #{@customer_id} not found"
  end
end
