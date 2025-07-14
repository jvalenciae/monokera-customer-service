FactoryBot.define do
  factory :customer do
    customer_name { Faker::Name.name }
    address { Faker::Address.full_address }
    orders_count { Faker::Number.between(from: 0, to: 100) }
  end
end
