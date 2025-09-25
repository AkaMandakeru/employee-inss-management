FactoryBot.define do
  factory :employee do
    sequence(:name) { |n| "Employee #{n}" }
    sequence(:document) { |n| "#{n.to_s.rjust(11, '0')}" }
    salary { 3000.00 }
    employee_type { "employee" }
    birthdate { Date.new(1990, 1, 1) }
    salary_discount { 270.00 }

    trait :domestic_employee do
      employee_type { "domestic_employee" }
      salary { 2500.00 }
      salary_discount { 225.00 }
    end

    trait :worker do
      employee_type { "worker" }
      salary { 4000.00 }
      salary_discount { 360.00 }
    end

    trait :with_address do
      after(:create) do |employee|
        create(:address, employee: employee)
      end
    end

    trait :with_contacts do
      after(:create) do |employee|
        create(:contact, :phone, employee: employee)
        create(:contact, :email, employee: employee)
      end
    end

    trait :complete do
      with_address
      with_contacts
    end
  end
end
