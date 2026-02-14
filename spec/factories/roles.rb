FactoryBot.define do
  factory :role do
    sequence(:name) { |n| "Test Role #{n}" }
    sequence(:position) { |n| n }
  end
end
