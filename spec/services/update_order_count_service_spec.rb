require 'rails_helper'

RSpec.describe UpdateOrderCountService do
  let(:customer) { create(:customer, orders_count: 5) }
  let(:service) { described_class.new(customer.id) }

  describe '#call' do
    it 'increments the orders_count by 1' do
      expect { service.call }.to change { customer.reload.orders_count }.by(1)
    end

    it 'returns the updated customer' do
      result = service.call
      expect(result).to eq(customer.reload)
    end

    it 'raises ArgumentError when customer is not found' do
      invalid_service = described_class.new(999)
      expect { invalid_service.call }.to raise_error(ArgumentError, /Customer with ID 999 not found/)
    end
  end

  describe '#initialize' do
    it 'accepts a customer_id parameter' do
      expect { described_class.new(1) }.not_to raise_error
    end
  end
end
