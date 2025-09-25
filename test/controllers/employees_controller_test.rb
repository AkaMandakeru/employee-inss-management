require "test_helper"

class EmployeesControllerTest < ActionDispatch::IntegrationTest
  def setup
    @employee = Employee.create!(
      name: "John Doe",
      document: "12345678901",
      salary: 3000.00,
      employee_type: "employee",
      birthdate: Date.new(1990, 1, 1)
    )

    @employee_params = {
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

  test "should get index" do
    get employees_url
    assert_response :success
    assert_select "h1", "Employees"
  end

  test "should get new" do
    get new_employee_url
    assert_response :success
    assert_select "h1", "New Employee"
  end

  test "should create employee with valid parameters" do
    assert_difference('Employee.count') do
      post employees_url, params: { employee: @employee_params }
    end

    assert_redirected_to employees_path
    follow_redirect!
    assert_select ".alert-success", "Employee was successfully created."

    created_employee = Employee.last
    assert_equal "Jane Smith", created_employee.name
    assert_equal "employee", created_employee.employee_type
    assert_equal 2500.00, created_employee.salary
    assert_equal 225.00, created_employee.salary_discount
    assert_equal 1, created_employee.addresses.count
    assert_equal 2, created_employee.contacts.count
  end

  test "should not create employee with invalid parameters" do
    invalid_params = @employee_params.dup
    invalid_params[:name] = nil

    assert_no_difference('Employee.count') do
      post employees_url, params: { employee: invalid_params }
    end

    assert_response :unprocessable_entity
    assert_select ".form-group .field_with_errors"
  end

  test "should show employee" do
    get employee_url(@employee)
    assert_response :success
    assert_select "h1", @employee.name
    assert_select "p", /#{@employee.document}/
    assert_select "p", /#{@employee.salary}/
  end

  test "should get edit" do
    get edit_employee_url(@employee)
    assert_response :success
    assert_select "h1", "Edit Employee"
    assert_select "input[value=?]", @employee.name
  end

  test "should update employee with valid parameters" do
    patch employee_url(@employee), params: {
      employee: {
        name: "Updated Name",
        salary: 3500.00,
        salary_discount: 315.00
      }
    }

    assert_redirected_to employees_path
    follow_redirect!
    assert_select ".alert-success", "Employee was successfully updated."

    @employee.reload
    assert_equal "Updated Name", @employee.name
    assert_equal 3500.00, @employee.salary
    assert_equal 315.00, @employee.salary_discount
  end

  test "should not update employee with invalid parameters" do
    patch employee_url(@employee), params: {
      employee: { name: nil }
    }

    assert_response :unprocessable_entity
    assert_select ".form-group .field_with_errors"
  end

  test "should destroy employee" do
    assert_difference('Employee.count', -1) do
      delete employee_url(@employee)
    end

    assert_redirected_to employees_path
    follow_redirect!
    assert_select ".alert-success", "Employee was successfully deleted."
  end

  test "should build addresses and contacts in new action" do
    get new_employee_url

    # Check that form has address fields
    assert_select "input[name*='addresses_attributes'][name*='street']"
    assert_select "input[name*='addresses_attributes'][name*='city']"

    # Check that form has contact fields (up to 3)
    contact_inputs = css_select("input[name*='contacts_attributes'][name*='contact_type']")
    assert contact_inputs.length >= 3, "Should have at least 3 contact type inputs"
  end

  test "should build additional addresses in edit action if none exist" do
    get edit_employee_url(@employee)

    # Should have at least one address form
    assert_select "input[name*='addresses_attributes'][name*='street']"
  end

  test "should build additional contacts in edit action up to 3 total" do
    get edit_employee_url(@employee)

    # Should have exactly 3 contact forms
    contact_inputs = css_select("input[name*='contacts_attributes'][name*='contact_type']")
    assert_equal 3, contact_inputs.length
  end

  test "should handle nested attributes for addresses" do
    post employees_url, params: {
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
    assert_equal 1, created_employee.addresses.count
    address = created_employee.addresses.first
    assert_equal "456 Oak Ave", address.street
    assert_equal "Another City", address.city
  end

  test "should handle nested attributes for contacts" do
    post employees_url, params: {
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
    assert_equal 2, created_employee.contacts.count

    phone_contact = created_employee.contacts.find_by(contact_type: "phone")
    assert_equal "555-0123", phone_contact.contact_content

    email_contact = created_employee.contacts.find_by(contact_type: "email")
    assert_equal "test@example.com", email_contact.contact_content
  end

  test "should include associations in show action" do
    # Create addresses and contacts for the employee
    @employee.addresses.create!(
      street: "123 Test St",
      city: "Test City",
      state: "TS",
      zipcode: "12345"
    )
    @employee.contacts.create!(
      contact_type: "phone",
      contact_content: "123-456-7890"
    )

    get employee_url(@employee)

    # Should display address information
    assert_select "p", /123 Test St/
    assert_select "p", /Test City/

    # Should display contact information
    assert_select "p", /123-456-7890/
  end

  test "should paginate employees in index" do
    # Create additional employees to test pagination
    6.times do |i|
      Employee.create!(
        name: "Employee #{i}",
        document: "#{i}2345678901",
        salary: 1000.00 + (i * 100),
        employee_type: "employee",
        birthdate: Date.new(1990, 1, 1)
      )
    end

    get employees_url
    assert_response :success

    # Should display pagination controls
    assert_select ".pagination"
  end
end
