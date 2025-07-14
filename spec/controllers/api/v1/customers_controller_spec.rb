require 'rails_helper'

RSpec.describe Api::V1::CustomersController, type: :controller do
  let(:customer) { create(:customer, customer_name: 'John Doe', address: '123 Main St', orders_count: 5) }

  describe 'GET #show' do
    context 'when customer exists' do
      before do
        get :show, params: { id: customer.id }
      end

      it 'returns http success' do
        expect(response).to have_http_status(:ok)
      end

      it 'returns customer data in the correct format' do
        json_response = JSON.parse(response.body)

        expect(json_response).to have_key('data')
        expect(json_response['data']).to include(
          'id' => customer.id,
          'customer_name' => 'John Doe',
          'address' => '123 Main St',
          'orders_count' => 5
        )
      end

      it 'includes all required fields' do
        json_response = JSON.parse(response.body)
        customer_data = json_response['data']

        expect(customer_data).to have_key('customer_name')
        expect(customer_data).to have_key('address')
        expect(customer_data).to have_key('orders_count')
      end
    end

    context 'when customer does not exist' do
      before do
        get :show, params: { id: 99999 }
      end

      it 'returns http not found' do
        expect(response).to have_http_status(:not_found)
      end

      it 'returns error message' do
        json_response = JSON.parse(response.body)

        expect(json_response).to have_key('error')
        expect(json_response['error']).to eq('Resource not found')
      end
    end

    context 'with different customer data' do
      let(:customer_with_zero_orders) { create(:customer, customer_name: 'Jane Smith', address: '456 Oak Ave', orders_count: 0) }

      before do
        get :show, params: { id: customer_with_zero_orders.id }
      end

      it 'returns correct data for customer with zero orders' do
        json_response = JSON.parse(response.body)

        expect(json_response['data']).to include(
          'customer_name' => 'Jane Smith',
          'address' => '456 Oak Ave',
          'orders_count' => 0
        )
      end
    end
  end
end
