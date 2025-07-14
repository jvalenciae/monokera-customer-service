require 'rails_helper'

RSpec.describe Customer, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:customer_name) }
    it { should validate_presence_of(:address) }
    it { should validate_numericality_of(:orders_count).is_greater_than_or_equal_to(0) }
  end

  describe '.increment_order_count' do
    let(:customer) { create(:customer, orders_count: 3) }

    it 'increments the orders_count by 1' do
      expect { Customer.increment_order_count(customer.id) }.to change { customer.reload.orders_count }.by(1)
    end

    it 'returns the updated customer' do
      result = Customer.increment_order_count(customer.id)
      expect(result).to eq(customer.reload)
    end
  end
end
