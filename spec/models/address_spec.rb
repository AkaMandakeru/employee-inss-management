require 'rails_helper'

RSpec.describe Address, type: :model do
  describe 'associations' do
    let(:employee) { create(:employee) }
    let(:address) { build(:address, employee: employee) }

    it 'belongs to employee' do
      expect(address.employee).to eq(employee)
    end

    it 'is valid with valid attributes' do
      expect(address).to be_valid
    end
  end

  describe 'association' do
    let(:employee) { create(:employee) }

    it 'can belong to an employee' do
      address = create(:address, employee: employee)
      expect(address.employee).to eq(employee)
    end
  end

  describe 'dependent destruction' do
    let(:employee) { create(:employee) }
    let!(:address) { create(:address, employee: employee) }

    it 'is destroyed when employee is destroyed' do
      expect { employee.destroy }.to change(Address, :count).by(-1)
    end
  end

  describe 'attributes' do
    let(:employee) { create(:employee) }
    let(:address) { build(:address, employee: employee) }

    it 'allows blank fields' do
      address.street = ""
      address.city = ""
      address.state = ""

      # Address should still be valid as it might be optional
      expect(address).to be_valid
    end

    it 'saves with all fields populated' do
      address.save!

      expect(address.street).to eq("123 Main Street")
      expect(address.number).to eq("456")
      expect(address.city).to eq("Test City")
      expect(address.state).to eq("TS")
      expect(address.zipcode).to eq("12345")
      expect(address.neighborhood).to eq("Downtown")
      expect(address.complement).to eq("Apt 101")
    end
  end

  describe 'factory' do
    it 'creates a valid address' do
      address = create(:address)
      expect(address).to be_valid
      expect(address).to be_persisted
    end

    it 'creates residential address with trait' do
      address = create(:address, :residential)
      expect(address.street).to eq("456 Residential Ave")
      expect(address.city).to eq("Residential City")
    end

    it 'creates commercial address with trait' do
      address = create(:address, :commercial)
      expect(address.street).to eq("789 Business Blvd")
      expect(address.city).to eq("Business City")
    end

    it 'creates inactive address with trait' do
      address = create(:address, :inactive)
      expect(address.status).to eq(0)
    end
  end
end
