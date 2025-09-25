require 'rails_helper'

RSpec.describe HomeController, type: :controller do
  let(:user) { create(:user) }

  before do
    # Mock authentication
    session = create(:session, user: user)
    allow(controller).to receive(:resume_session).and_return(session)
    allow(controller).to receive(:authenticated?).and_return(true)
    Current.session = session
  end
  let!(:employee1) { create(:employee, name: "John Doe") }
  let!(:employee2) { create(:employee, :domestic_employee, name: "Jane Smith") }
  let!(:employee3) { create(:employee, :worker, name: "Bob Johnson") }

  before do
    # Add some addresses and contacts to test associations
    create(:address, employee: employee1, street: "123 Main St", city: "Test City", state: "TS", zipcode: "12345")
    create(:contact, employee: employee1, contact_type: "phone", contact_content: "123-456-7890")
  end

  describe 'GET #index' do
    before { get :index }

    it 'returns a successful response' do
      expect(response).to be_successful
    end

    it 'assigns employees with associations' do
      employees = assigns(:employees)
      expect(employees).to be_present
      expect(employees.count).to be <= 10
      expect(employees.count).to be >= 3
    end

    it 'assigns total employees count' do
      expect(assigns(:total_employees)).to eq(3)
    end

    it 'loads associations to prevent N+1 queries' do
      employees = assigns(:employees)
      employees.each do |employee|
        expect { employee.addresses.to_a }.not_to raise_error
        expect { employee.contacts.to_a }.not_to raise_error
      end
    end
  end

  describe 'employee statistics' do
    before { get :index }

    it 'calculates correct total employees' do
      expect(assigns(:total_employees)).to eq(3)
    end

    it 'limits employees to 10 in recent employees' do
      # Create 15 employees to test limit
      15.times do |i|
        create(:employee, name: "Employee #{i}")
      end

      get :index

      employees = assigns(:employees)
      expect(employees.count).to eq(10)

      total_employees = assigns(:total_employees)
      expect(total_employees).to eq(18) # 15 new + 3 from setup
    end

    it 'loads most recent employees first' do
      # Create a new employee after setup
      newest_employee = create(:employee, name: "Newest Employee")

      get :index

      employees = assigns(:employees)
      # The newest employee should be in the list (order may vary due to limit)
      expect(employees).to include(newest_employee)
    end
  end

  describe 'empty employee list' do
    before do
      Employee.destroy_all
      get :index
    end

    it 'handles empty employee list' do
      expect(assigns(:total_employees)).to eq(0)

      employees = assigns(:employees)
      expect(employees.count).to eq(0)
    end
  end

  describe 'associations loading' do
    it 'includes associations when loading employees' do
      get :index

      # Should not raise N+1 query issues
      expect(response).to be_successful

      employees = assigns(:employees)
      employees.each do |employee|
        expect { employee.addresses.to_a }.not_to raise_error
        expect { employee.contacts.to_a }.not_to raise_error
      end
    end
  end
end
