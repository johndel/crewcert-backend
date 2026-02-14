FactoryBot.define do
  factory :vessel do
    sequence(:name) { |n| "M/V Test Vessel #{n}" }
    sequence(:imo) { |n| "IMO#{n.to_s.rjust(7, '0')}" }
    management_company { "Test Management Co." }
  end
end
