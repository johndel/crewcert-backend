FactoryBot.define do
  factory :vessel do
    sequence(:name) { |n| "M/V Test Vessel #{n}" }
    sequence(:imo) { |n| (9000000 + n).to_s }
    management_company { "Test Management Co." }

    trait :without_imo do
      imo { nil }
    end
  end
end
