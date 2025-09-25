require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  def setup
    # Create test employees
    @employee1 = Employee.create!(
      name: "John Doe",
      document: "11111111111",
      salary: 3000.00,
      employee_type: "employee",
      birthdate: Date.new(1990, 1, 1)
    )

    @employee2 = Employee.create!(
      name: "Jane Smith",
      document: "22222222222",
      salary: 2500.00,
      employee_type: "domestic_employee",
      birthdate: Date.new(1985, 5, 15)
    )

    @employee3 = Employee.create!(
      name: "Bob Johnson",
      document: "33333333333",
      salary: 4000.00,
      employee_type: "worker",
      birthdate: Date.new(1988, 8, 20)
    )

    # Add some addresses and contacts to test associations
    @employee1.addresses.create!(
      street: "123 Main St",
      city: "Test City",
      state: "TS",
      zipcode: "12345"
    )

    @employee1.contacts.create!(
      contact_type: "phone",
      contact_content: "123-456-7890"
    )
  end

  test "should get index" do
    get root_url
    assert_response :success
    assert_select "h1", "Dashboard"
  end

  test "should load employees with associations" do
    get root_url

    employees = assigns(:employees)
    assert_not_nil employees
    assert employees.count <= 10
    assert employees.count >= 3

    # Check that associations are loaded (no N+1 queries)
    employees.each do |employee|
      assert_nothing_raised { employee.addresses.to_a }
      assert_nothing_raised { employee.contacts.to_a }
    end
  end

  test "should set total employees count" do
    get root_url

    total_employees = assigns(:total_employees)
    assert_not_nil total_employees
    assert_equal 3, total_employees
  end

  test "should display employee statistics cards" do
    get root_url

    # Check for statistics cards
    assert_select ".card" do
      assert_select "h5", "Total Employees"
      assert_select "h3", "3" # Total count
    end

    assert_select ".card" do
      assert_select "h5", "Regular Employees"
      assert_select "h3", "1" # Employee type count
    end

    assert_select ".card" do
      assert_select "h5", "Total Payroll"
      assert_select "h3", /R\$\s*9\.500,00/ # Total salary formatted
    end
  end

  test "should display recent employees table" do
    get root_url

    # Check for table structure
    assert_select "table.table" do
      assert_select "thead" do
        assert_select "th", "Name"
        assert_select "th", "Document"
        assert_select "th", "Type"
        assert_select "th", "Salary"
        assert_select "th", "Actions"
      end

      assert_select "tbody" do
        # Should have 3 employee rows
        assert_select "tr", 3
      end
    end
  end

  test "should display employee type badges correctly" do
    get root_url

    # Check for employee type badges
    assert_select "span.badge" do
      assert_select "span.badge.bg-primary", "Employee"
      assert_select "span.badge.bg-info", "Domestic Employee"
      assert_select "span.badge.bg-warning", "Worker"
    end
  end

  test "should format salary correctly" do
    get root_url

    # Check for properly formatted salary
    assert_select "td", /R\$\s*3\.000,00/
    assert_select "td", /R\$\s*2\.500,00/
    assert_select "td", /R\$\s*4\.000,00/
  end

  test "should have action buttons for each employee" do
    get root_url

    # Check for action buttons
    assert_select "a[href=?]", employee_path(@employee1), text: "View"
    assert_select "a[href=?]", edit_employee_path(@employee1), text: "Edit"
    assert_select "a[href=?]", employee_path(@employee1), text: "Delete"
  end

  test "should display navbar with correct links" do
    get root_url

    assert_select "nav.navbar" do
      assert_select "a[href=?]", root_path, text: "Home"
      assert_select "a[href=?]", employees_path, text: "Employees"
      assert_select "a[href=?]", reports_path, text: "Reports"
    end
  end

  test "should have add new employee button" do
    get root_url

    assert_select "a.btn.btn-primary[href=?]", new_employee_path, text: "Add New Employee"
  end

  test "should handle empty employee list" do
    Employee.destroy_all

    get root_url
    assert_response :success

    total_employees = assigns(:total_employees)
    assert_equal 0, total_employees

    employees = assigns(:employees)
    assert_equal 0, employees.count

    # Should still display statistics cards with zero values
    assert_select ".card" do
      assert_select "h5", "Total Employees"
      assert_select "h3", "0"
    end
  end

  test "should limit employees to 10 in recent employees" do
    # Create 15 employees to test limit
    15.times do |i|
      Employee.create!(
        name: "Employee #{i}",
        document: "#{i}2345678901",
        salary: 1000.00,
        employee_type: "employee",
        birthdate: Date.new(1990, 1, 1)
      )
    end

    get root_url

    employees = assigns(:employees)
    assert_equal 10, employees.count

    total_employees = assigns(:total_employees)
    assert_equal 18, total_employees # 15 new + 3 from setup
  end

  test "should load most recent employees first" do
    # Create a new employee after setup
    newest_employee = Employee.create!(
      name: "Newest Employee",
      document: "99999999999",
      salary: 5000.00,
      employee_type: "employee",
      birthdate: Date.new(1995, 1, 1)
    )

    get root_url

    employees = assigns(:employees)
    # The newest employee should be first in the list
    assert_equal newest_employee, employees.first
  end
end
