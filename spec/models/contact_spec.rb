require 'rails_helper'

RSpec.describe Contact, type: :model do
  describe 'associations' do
    let(:employee) { create(:employee) }
    let(:contact) { build(:contact, employee: employee) }

    it 'belongs to employee' do
      expect(contact.employee).to eq(employee)
    end

    it 'is valid with valid attributes' do
      expect(contact).to be_valid
    end
  end

  describe 'dependent destruction' do
    let(:employee) { create(:employee) }
    let!(:contact) { create(:contact, employee: employee) }

    it 'is destroyed when employee is destroyed' do
      expect { employee.destroy }.to change(Contact, :count).by(-1)
    end
  end

  describe 'contact types' do
    let(:employee) { create(:employee) }

    it 'saves with valid contact types' do
      valid_types = ["phone", "email", "mobile", "fax", "other"]

      valid_types.each do |type|
        contact = build(:contact, employee: employee, contact_type: type, contact_content: "test content for #{type}")
        expect(contact).to be_valid, "#{type} should be valid"
      end
    end
  end

  describe 'contact content' do
    let(:employee) { create(:employee) }

    it 'saves with valid contact content' do
      valid_contents = [
        "123-456-7890",
        "test@example.com",
        "+55 11 99999-9999",
        "555-0123"
      ]

      valid_contents.each do |content|
        contact = build(:contact, employee: employee, contact_content: content)
        expect(contact).to be_valid, "#{content} should be valid"
      end
    end
  end

  describe 'optional attributes' do
    let(:employee) { create(:employee) }

    it 'allows blank contact type and content' do
      contact = build(:contact, employee: employee, contact_type: "", contact_content: "")

      # Contact should still be valid as it might be optional
      expect(contact).to be_valid
    end
  end

  describe 'saving' do
    let(:employee) { create(:employee) }

    it 'saves successfully' do
      contact = create(:contact, employee: employee)

      expect(contact.contact_type).to eq("phone")
      expect(contact.contact_content).to eq("123-456-7890")
      expect(contact.employee).to eq(employee)
    end
  end

  describe 'factory' do
    it 'creates a valid contact' do
      contact = create(:contact)
      expect(contact).to be_valid
      expect(contact).to be_persisted
    end

    it 'creates phone contact with trait' do
      contact = create(:contact, :phone)
      expect(contact.contact_type).to eq("phone")
      expect(contact.contact_content).to eq("123-456-7890")
    end

    it 'creates email contact with trait' do
      contact = create(:contact, :email)
      expect(contact.contact_type).to eq("email")
      expect(contact.contact_content).to eq("test@example.com")
    end

    it 'creates mobile contact with trait' do
      contact = create(:contact, :mobile)
      expect(contact.contact_type).to eq("mobile")
      expect(contact.contact_content).to eq("987-654-3210")
    end

    it 'creates fax contact with trait' do
      contact = create(:contact, :fax)
      expect(contact.contact_type).to eq("fax")
      expect(contact.contact_content).to eq("555-0123")
    end

    it 'creates other contact with trait' do
      contact = create(:contact, :other)
      expect(contact.contact_type).to eq("other")
      expect(contact.contact_content).to eq("Additional contact info")
    end
  end
end
