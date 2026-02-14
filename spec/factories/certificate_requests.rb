FactoryBot.define do
  factory :certificate_request do
    crew_member
    status { 'pending' }

    trait :sent do
      status { 'sent' }
      sent_at { Time.current }
    end

    trait :submitted do
      status { 'submitted' }
      sent_at { 1.day.ago }
      submitted_at { Time.current }
    end

    trait :expired do
      status { 'expired' }
      expires_at { 1.day.ago }
    end
  end
end
