FactoryBot.define do
  factory :super_admin do
    sequence(:email) { |n| "superadmin#{n}@example.com" }
    password { "password123" }
    password_confirmation { "password123" }
  end
end
