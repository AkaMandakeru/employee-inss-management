FactoryBot.define do
  factory :session do
    association :user
    # Session attributes will be handled by the authentication system
  end
end
