FactoryBot.define do
  factory :certificate do
    crew_member
    certificate_type
    issue_date { 1.year.ago.to_date }
    expiry_date { 4.years.from_now.to_date }
    status { 'pending' }

    trait :verified do
      status { 'verified' }
      verified_at { Time.current }
      association :verified_by, factory: :user
    end

    trait :rejected do
      status { 'rejected' }
      verified_at { Time.current }
      association :verified_by, factory: :user
    end

    trait :expired do
      expiry_date { 1.month.ago.to_date }
    end

    trait :expiring_soon do
      expiry_date { 2.weeks.from_now.to_date }
    end
  end
end
