require 'rails_helper'

RSpec.describe EmployeesController, type: :controller do
  let(:user) { create(:user) }
  let(:employee) { create(:employee) }

  before do
    # Mock authentication
    session = create(:session, user: user)
    allow(controller).to receive(:resume_session).and_return(session)
    allow(controller).to receive(:authenticated?).and_return(true)
    Current.session = session
  end
  let(:valid_attributes) do
    {
      employee_type: "employee",
      name: "Jane Smith",
      birthdate: "1985-05-15",
      document: "98765432100",
      salary: 2500.00,
      salary_discount: 225.00,
      addresses_attributes: {
        "0" => {
          street: "123 Main St",
          number: "456",
          city: "Test City",
          state: "TS",
          zipcode: "12345",
          neighborhood: "Downtown",
          complement: "Apt 101"
        }
      },
      contacts_attributes: {
        "0" => {
          contact_type: "phone",
          contact_content: "123-456-7890"
        },
        "1" => {
          contact_type: "email",
          contact_content: "jane@example.com"
        }
      }
    }
  end
  let(:invalid_attributes) { { name: nil, document: nil, salary: nil } }

  describe 'GET #index' do
    it 'returns a successful response' do
      get :index
      expect(response).to be_successful
    end

    it 'assigns @employees' do
      employee # Create employee
      get :index
      expect(assigns(:employees)).to include(employee)
    end

    it 'includes associations to prevent N+1 queries' do
      employee # Create employee
      get :index
      # Should not raise N+1 query issues
      expect(response).to be_successful
    end
  end

  describe 'GET #show' do
    it 'returns a successful response' do
      get :show, params: { id: employee.id }
      expect(response).to be_successful
    end

    it 'assigns the requested employee' do
      get :show, params: { id: employee.id }
      expect(assigns(:employee)).to eq(employee)
    end

    it 'includes associations' do
      address = create(:address, employee: employee)
      contact = create(:contact, employee: employee)

      get :show, params: { id: employee.id }

      expect(assigns(:employee).addresses).to include(address)
      expect(assigns(:employee).contacts).to include(contact)
    end
  end

  describe 'GET #new' do
    it 'returns a successful response' do
      get :new
      expect(response).to be_successful
    end

    it 'assigns a new employee' do
      get :new
      expect(assigns(:employee)).to be_a_new(Employee)
    end

    it 'builds one address' do
      get :new
      expect(assigns(:employee).addresses.length).to eq(1)
    end

    it 'builds three contacts' do
      get :new
      expect(assigns(:employee).contacts.length).to eq(3)
    end
  end

  describe 'POST #create' do
    context 'with valid parameters' do
      it 'creates a new Employee' do
        expect {
          post :create, params: { employee: valid_attributes }
        }.to change(Employee, :count).by(1)
      end

      it 'redirects to employees index' do
        post :create, params: { employee: valid_attributes }
        expect(response).to redirect_to(employees_path)
      end

      it 'sets a success notice' do
        post :create, params: { employee: valid_attributes }
        expect(flash[:notice]).to eq('Employee was successfully created.')
      end

      it 'creates associated address' do
        post :create, params: { employee: valid_attributes }
        created_employee = Employee.last
        expect(created_employee.addresses.count).to eq(1)
        expect(created_employee.addresses.first.street).to eq("123 Main St")
      end

      it 'creates associated contacts' do
        post :create, params: { employee: valid_attributes }
        created_employee = Employee.last
        expect(created_employee.contacts.count).to eq(2)
        expect(created_employee.contacts.pluck(:contact_type)).to include("phone", "email")
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new Employee' do
        expect {
          post :create, params: { employee: invalid_attributes }
        }.not_to change(Employee, :count)
      end

      it 'renders the new template' do
        post :create, params: { employee: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'GET #edit' do
    it 'returns a successful response' do
      get :edit, params: { id: employee.id }
      expect(response).to be_successful
    end

    it 'assigns the requested employee' do
      get :edit, params: { id: employee.id }
      expect(assigns(:employee)).to eq(employee)
    end

    it 'builds address if none exist' do
      get :edit, params: { id: employee.id }
      expect(assigns(:employee).addresses.length).to eq(1)
    end

    it 'builds additional contacts up to 3 total' do
      get :edit, params: { id: employee.id }
      expect(assigns(:employee).contacts.length).to eq(3)
    end

    it 'preserves existing addresses' do
      existing_address = create(:address, employee: employee)
      get :edit, params: { id: employee.id }
      expect(assigns(:employee).addresses).to include(existing_address)
    end

    it 'preserves existing contacts and builds additional ones' do
      existing_contact = create(:contact, employee: employee)
      get :edit, params: { id: employee.id }
      expect(assigns(:employee).contacts).to include(existing_contact)
      expect(assigns(:employee).contacts.length).to eq(3)
    end
  end

  describe 'PATCH #update' do
    context 'with valid parameters' do
      let(:new_attributes) { { name: "Updated Name", salary: 3500.00, salary_discount: 315.00 } }

      it 'updates the requested employee' do
        patch :update, params: { id: employee.id, employee: new_attributes }
        employee.reload
        expect(employee.name).to eq("Updated Name")
        expect(employee.salary).to eq(3500.00)
        expect(employee.salary_discount).to eq(315.00)
      end

      it 'redirects to employees index' do
        patch :update, params: { id: employee.id, employee: new_attributes }
        expect(response).to redirect_to(employees_path)
      end

      it 'sets a success notice' do
        patch :update, params: { id: employee.id, employee: new_attributes }
        expect(flash[:notice]).to eq('Employee was successfully updated.')
      end
    end

    context 'with invalid parameters' do
      it 'does not update the employee' do
        original_name = employee.name
        patch :update, params: { id: employee.id, employee: invalid_attributes }
        employee.reload
        expect(employee.name).to eq(original_name)
      end

      it 'renders the edit template' do
        patch :update, params: { id: employee.id, employee: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested employee' do
      employee # Create the employee
      expect {
        delete :destroy, params: { id: employee.id }
      }.to change(Employee, :count).by(-1)
    end

    it 'redirects to employees index' do
      delete :destroy, params: { id: employee.id }
      expect(response).to redirect_to(employees_path)
    end

    it 'sets a success notice' do
      delete :destroy, params: { id: employee.id }
      expect(flash[:notice]).to eq('Employee was successfully deleted.')
    end
  end

  describe 'nested attributes handling' do
    it 'handles nested attributes for addresses' do
      post :create, params: {
        employee: {
          name: "Test Employee",
          document: "11111111111",
          salary: 2000.00,
          employee_type: "employee",
          addresses_attributes: {
            "0" => {
              street: "456 Oak Ave",
              city: "Another City",
              state: "AC",
              zipcode: "54321"
            }
          }
        }
      }

      created_employee = Employee.last
      expect(created_employee.addresses.count).to eq(1)
      address = created_employee.addresses.first
      expect(address.street).to eq("456 Oak Ave")
      expect(address.city).to eq("Another City")
    end

    it 'handles nested attributes for contacts' do
      post :create, params: {
        employee: {
          name: "Test Employee",
          document: "22222222222",
          salary: 2000.00,
          employee_type: "employee",
          contacts_attributes: {
            "0" => {
              contact_type: "phone",
              contact_content: "555-0123"
            },
            "1" => {
              contact_type: "email",
              contact_content: "test@example.com"
            }
          }
        }
      }

      created_employee = Employee.last
      expect(created_employee.contacts.count).to eq(2)

      phone_contact = created_employee.contacts.find_by(contact_type: "phone")
      expect(phone_contact.contact_content).to eq("555-0123")

      email_contact = created_employee.contacts.find_by(contact_type: "email")
      expect(email_contact.contact_content).to eq("test@example.com")
    end
  end

  describe 'private methods' do
    describe '#set_employee' do
      it 'finds the correct employee' do
        controller.params = { id: employee.id }
        controller.send(:set_employee)
        expect(assigns(:employee)).to eq(employee)
      end
    end

    describe '#employee_params' do
      it 'permits the correct parameters' do
        params = ActionController::Parameters.new({
          employee: {
            employee_type: "employee",
            name: "Test",
            document: "12345678901",
            salary: 1000.00,
            salary_discount: 90.00,
            addresses_attributes: { "0" => { street: "Test St" } },
            contacts_attributes: { "0" => { contact_type: "phone", contact_content: "123-456-7890" } }
          }
        })

        controller.params = params
        permitted_params = controller.send(:employee_params)

        expect(permitted_params).to include(:employee_type, :name, :document, :salary, :salary_discount)
        expect(permitted_params[:addresses_attributes]).to be_present
        expect(permitted_params[:contacts_attributes]).to be_present
      end
    end
  end
end
