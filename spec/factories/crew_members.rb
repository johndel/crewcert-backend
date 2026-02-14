FactoryBot.define do
  factory :crew_member do
    vessel
    role
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    email { Faker::Internet.unique.email }
    phone { Faker::PhoneNumber.phone_number }
  end
end
