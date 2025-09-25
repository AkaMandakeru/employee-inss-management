FactoryBot.define do
  factory :contact do
    contact_type { "phone" }
    contact_content { "123-456-7890" }
    association :employee

    trait :phone do
      contact_type { "phone" }
      contact_content { "123-456-7890" }
    end

    trait :email do
      contact_type { "email" }
      contact_content { "test@example.com" }
    end

    trait :mobile do
      contact_type { "mobile" }
      contact_content { "987-654-3210" }
    end

    trait :fax do
      contact_type { "fax" }
      contact_content { "555-0123" }
    end

    trait :other do
      contact_type { "other" }
      contact_content { "Additional contact info" }
    end
  end
end
