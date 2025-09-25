FactoryBot.define do
  factory :address do
    street { "123 Main Street" }
    number { "456" }
    city { "Test City" }
    state { "TS" }
    zipcode { "12345" }
    neighborhood { "Downtown" }
    complement { "Apt 101" }
    status { 1 }
    association :employee

    trait :residential do
      street { "456 Residential Ave" }
      city { "Residential City" }
    end

    trait :commercial do
      street { "789 Business Blvd" }
      city { "Business City" }
    end

    trait :inactive do
      status { 0 }
    end
  end
end
