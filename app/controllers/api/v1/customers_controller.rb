module Api
  module V1
    class CustomersController < ApplicationController
      def show
        customer = Customer.find(params[:id])

        render_success(customer)
      end
    end
  end
end
