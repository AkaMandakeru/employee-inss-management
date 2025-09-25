require 'rails_helper'

RSpec.describe Employee, type: :model do
  describe 'validations' do
    let(:employee) { build(:employee) }

    it 'is valid with valid attributes' do
      expect(employee).to be_valid
    end

    describe 'name' do
      it 'is required' do
        employee.name = nil
        expect(employee).not_to be_valid
        expect(employee.errors[:name]).to include("can't be blank")
      end

      it 'must have minimum length of 2 characters' do
        employee.name = 'A'
        expect(employee).not_to be_valid
        expect(employee.errors[:name]).to include("is too short (minimum is 2 characters)")
      end
    end

    describe 'document' do
      it 'is required' do
        employee.document = nil
        expect(employee).not_to be_valid
        expect(employee.errors[:document]).to include("can't be blank")
      end

      it 'must be unique' do
        employee.save!
        duplicate_employee = build(:employee, document: employee.document)
        expect(duplicate_employee).not_to be_valid
        expect(duplicate_employee.errors[:document]).to include("has already been taken")
      end
    end

    describe 'salary' do
      it 'is required' do
        employee.salary = nil
        expect(employee).not_to be_valid
        expect(employee.errors[:salary]).to include("can't be blank")
      end

      it 'must be greater than 0' do
        employee.salary = 0
        expect(employee).not_to be_valid
        expect(employee.errors[:salary]).to include("must be greater than 0")

        employee.salary = -100
        expect(employee).not_to be_valid
        expect(employee.errors[:salary]).to include("must be greater than 0")
      end
    end

    describe 'employee_type' do
      it 'is required' do
        employee.employee_type = nil
        expect(employee).not_to be_valid
        expect(employee.errors[:employee_type]).to include("can't be blank")
      end

      it 'accepts valid employee types' do
        valid_types = %w[employee domestic_employee worker]

        valid_types.each do |type|
          employee.employee_type = type
          expect(employee).to be_valid, "#{type} should be valid"
        end
      end

      it 'does not accept invalid employee type' do
        expect {
          employee.employee_type = "invalid_type"
        }.to raise_error(ArgumentError, "'invalid_type' is not a valid employee_type")
      end
    end
  end

  describe 'associations' do
    let(:employee) { create(:employee) }

    it 'has many addresses' do
      address1 = create(:address, employee: employee)
      address2 = create(:address, employee: employee)

      expect(employee.addresses).to include(address1, address2)
      expect(employee.addresses.count).to eq(2)
    end

    it 'has many contacts' do
      contact1 = create(:contact, employee: employee)
      contact2 = create(:contact, employee: employee)

      expect(employee.contacts).to include(contact1, contact2)
      expect(employee.contacts.count).to eq(2)
    end

    it 'destroys dependent addresses when employee is destroyed' do
      address = create(:address, employee: employee)

      expect { employee.destroy }.to change(Address, :count).by(-1)
    end

    it 'destroys dependent contacts when employee is destroyed' do
      contact = create(:contact, employee: employee)

      expect { employee.destroy }.to change(Contact, :count).by(-1)
    end
  end

  describe 'nested attributes' do
    let(:employee) { build(:employee) }

    it 'accepts nested attributes for addresses' do
      employee.addresses_attributes = {
        "0" => {
          street: "123 Main St",
          city: "Test City",
          state: "TS",
          zipcode: "12345"
        }
      }

      expect { employee.save }.to change(Address, :count).by(1)
    end

    it 'accepts nested attributes for contacts' do
      employee.contacts_attributes = {
        "0" => {
          contact_type: "phone",
          contact_content: "123-456-7890"
        }
      }

      expect { employee.save }.to change(Contact, :count).by(1)
    end

    it 'rejects blank nested attributes' do
      employee.addresses_attributes = {
        "0" => {
          street: "",
          city: "",
          state: "",
          zipcode: ""
        }
      }

      expect { employee.save }.not_to change(Address, :count)
    end
  end

  describe 'enums' do
    let(:employee) { build(:employee) }

    it 'has correct enum values' do
      expect(Employee.employee_types[:employee]).to eq(1)
      expect(Employee.employee_types[:domestic_employee]).to eq(2)
      expect(Employee.employee_types[:worker]).to eq(3)
    end

    it 'responds to employee type predicate methods' do
      employee.employee_type = "employee"
      expect(employee.employee?).to be true
      expect(employee.domestic_employee?).to be false
      expect(employee.worker?).to be false

      employee.employee_type = "domestic_employee"
      expect(employee.employee?).to be false
      expect(employee.domestic_employee?).to be true
      expect(employee.worker?).to be false

      employee.employee_type = "worker"
      expect(employee.employee?).to be false
      expect(employee.domestic_employee?).to be false
      expect(employee.worker?).to be true
    end
  end

  describe 'constants' do
    it 'has TYPES constant' do
      expected_types = %w[employee domestic_employee worker]
      expect(Employee::TYPES).to eq(expected_types)
    end
  end

  describe 'factory' do
    it 'creates a valid employee' do
      employee = create(:employee)
      expect(employee).to be_valid
      expect(employee).to be_persisted
    end

    it 'creates a domestic employee with trait' do
      employee = create(:employee, :domestic_employee)
      expect(employee.employee_type).to eq("domestic_employee")
      expect(employee.salary).to eq(2500.00)
    end

    it 'creates a worker with trait' do
      employee = create(:employee, :worker)
      expect(employee.employee_type).to eq("worker")
      expect(employee.salary).to eq(4000.00)
    end

    it 'creates employee with address using trait' do
      employee = create(:employee, :with_address)
      expect(employee.addresses.count).to eq(1)
      expect(employee.addresses.first.street).to eq("123 Main Street")
    end

    it 'creates employee with contacts using trait' do
      employee = create(:employee, :with_contacts)
      expect(employee.contacts.count).to eq(2)
      expect(employee.contacts.pluck(:contact_type)).to include("phone", "email")
    end

    it 'creates complete employee with all associations' do
      employee = create(:employee, :complete)
      expect(employee.addresses.count).to eq(1)
      expect(employee.contacts.count).to eq(2)
    end
  end
end
