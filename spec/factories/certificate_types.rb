FactoryBot.define do
  factory :certificate_type do
    sequence(:code) { |n| "CERT#{n.to_s.rjust(3, '0')}" }
    sequence(:name) { |n| "Test Certificate #{n}" }
    description { "A test certificate type" }
    validity_period_months { 60 }
  end
end
