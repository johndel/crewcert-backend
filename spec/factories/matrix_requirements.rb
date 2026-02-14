FactoryBot.define do
  factory :matrix_requirement do
    vessel
    role
    certificate_type
    requirement_level { 'M' }

    trait :optional do
      requirement_level { 'O' }
    end
  end
end
