FactoryBot.define do
  factory :user do
    sequence(:email_address) { |n| "user#{n}@example.com" }
    password { "password123" }
    password_confirmation { "password123" }

    trait :admin do
      email_address { "admin@example.com" }
      password { "admin123" }
      password_confirmation { "admin123" }
    end

    trait :with_sessions do
      after(:create) do |user|
        create(:session, user: user)
      end
    end
  end
end
