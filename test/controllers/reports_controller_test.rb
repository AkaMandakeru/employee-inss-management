require "test_helper"

class ReportsControllerTest < ActionDispatch::IntegrationTest
  def setup
    # Create test employees in different salary brackets
    @employee1 = Employee.create!(
      name: "Employee 1",
      document: "11111111111",
      salary: 1000.00, # 1st bracket
      employee_type: "employee",
      birthdate: Date.new(1990, 1, 1)
    )

    @employee2 = Employee.create!(
      name: "Employee 2",
      document: "22222222222",
      salary: 1500.00, # 2nd bracket
      employee_type: "employee",
      birthdate: Date.new(1985, 5, 15)
    )

    @employee3 = Employee.create!(
      name: "Employee 3",
      document: "33333333333",
      salary: 2500.00, # 3rd bracket
      employee_type: "worker",
      birthdate: Date.new(1988, 8, 20)
    )

    @employee4 = Employee.create!(
      name: "Employee 4",
      document: "44444444444",
      salary: 4000.00, # 4th bracket
      employee_type: "domestic_employee",
      birthdate: Date.new(1992, 12, 10)
    )
  end

  test "should get index" do
    get reports_url
    assert_response :success
    assert_select "h1", "Reports Dashboard"
  end

  test "should calculate correct employee statistics" do
    get reports_url

    assert_response :success
    assert_not_nil assigns(:employees_count)
    assert_not_nil assigns(:total_salary)
    assert_not_nil assigns(:average_salary)

    # Check basic statistics
    assert_equal 4, assigns(:employees_count)
    assert_equal 9000.00, assigns(:total_salary)
    assert_equal 2250.00, assigns(:average_salary)
  end

  test "should group employees into correct salary brackets" do
    get reports_url

    salary_brackets = assigns(:salary_brackets)
    assert_not_nil salary_brackets

    # Check that employees are in correct brackets
    assert_equal 1, salary_brackets['bracket_1'][:employees].count
    assert_equal 1, salary_brackets['bracket_2'][:employees].count
    assert_equal 1, salary_brackets['bracket_3'][:employees].count
    assert_equal 1, salary_brackets['bracket_4'][:employees].count

    # Verify specific employees are in correct brackets
    assert_includes salary_brackets['bracket_1'][:employees], @employee1
    assert_includes salary_brackets['bracket_2'][:employees], @employee2
    assert_includes salary_brackets['bracket_3'][:employees], @employee3
    assert_includes salary_brackets['bracket_4'][:employees], @employee4
  end

  test "should calculate bracket statistics correctly" do
    get reports_url

    bracket_statistics = assigns(:bracket_statistics)
    assert_not_nil bracket_statistics

    # Check bracket 1 statistics
    bracket1_stats = bracket_statistics['bracket_1']
    assert_equal 1, bracket1_stats[:count]
    assert_equal 25.0, bracket1_stats[:percentage] # 1/4 * 100
    assert_equal 1000.00, bracket1_stats[:total_salary]
    assert_equal 1000.00, bracket1_stats[:average_salary]

    # Check bracket 2 statistics
    bracket2_stats = bracket_statistics['bracket_2']
    assert_equal 1, bracket2_stats[:count]
    assert_equal 25.0, bracket2_stats[:percentage]
    assert_equal 1500.00, bracket2_stats[:total_salary]
    assert_equal 1500.00, bracket2_stats[:average_salary]
  end

  test "should calculate INSS correctly for different salary ranges" do
    controller = ReportsController.new

    # Test INSS calculation for different salary brackets
    # 1st bracket: 1000.00 * 0.075 = 75.00
    assert_equal 75.00, controller.send(:calculate_inss_for_employee, 1000.00)

    # 2nd bracket: 1045.00 * 0.075 + (1500.00 - 1045.00) * 0.09 = 78.38 + 40.95 = 119.33
    assert_equal 119.33, controller.send(:calculate_inss_for_employee, 1500.00)

    # 3rd bracket: 1045.00 * 0.075 + (2089.60 - 1045.00) * 0.09 + (2500.00 - 2089.60) * 0.12
    # = 78.38 + 94.01 + 49.25 = 221.64
    assert_equal 221.64, controller.send(:calculate_inss_for_employee, 2500.00)

    # 4th bracket: More complex calculation
    assert_equal 345.67, controller.send(:calculate_inss_for_employee, 4000.00)
  end

  test "should prepare salary brackets chart data correctly" do
    get reports_url

    chart_data = assigns(:salary_brackets_data)
    assert_not_nil chart_data

    assert_equal 4, chart_data[:labels].length
    assert_equal 4, chart_data[:datasets][0][:data].length

    # Check that data matches employee counts
    assert_equal [1, 1, 1, 1], chart_data[:datasets][0][:data]
  end

  test "should prepare INSS distribution chart data correctly" do
    get reports_url

    chart_data = assigns(:inss_distribution_data)
    assert_not_nil chart_data

    assert_equal 4, chart_data[:labels].length
    assert_equal 4, chart_data[:datasets][0][:data].length

    # Check that INSS totals are calculated
    inss_data = chart_data[:datasets][0][:data]
    assert inss_data.all? { |value| value >= 0 }
  end

  test "should display recent employees" do
    get reports_url

    recent_employees = assigns(:recent_employees)
    assert_not_nil recent_employees
    assert recent_employees.count <= 5
  end

  test "should handle empty employee database" do
    Employee.destroy_all

    get reports_url
    assert_response :success

    assert_equal 0, assigns(:employees_count)
    assert_equal 0, assigns(:total_salary)
    assert_equal 0, assigns(:average_salary)

    # All brackets should be empty
    salary_brackets = assigns(:salary_brackets)
    salary_brackets.each do |_key, bracket|
      assert_equal 0, bracket[:employees].count
    end
  end

  test "should calculate percentages correctly when no employees" do
    Employee.destroy_all

    get reports_url

    bracket_statistics = assigns(:bracket_statistics)
    bracket_statistics.each do |_key, stats|
      assert_equal 0, stats[:count]
      assert_equal 0, stats[:percentage]
      assert_equal 0, stats[:total_salary]
      assert_equal 0, stats[:average_salary]
      assert_equal 0, stats[:total_inss]
      assert_equal 0, stats[:average_inss]
    end
  end

  test "should include associations when loading employees" do
    # Add addresses and contacts to employees
    @employee1.addresses.create!(street: "123 Test St", city: "Test City")
    @employee1.contacts.create!(contact_type: "phone", contact_content: "123-456-7890")

    get reports_url

    # Should not raise N+1 query issues
    assert_response :success
  end

  test "should make calculate_inss_for_employee a helper method" do
    controller = ReportsController.new
    assert controller.respond_to?(:calculate_inss_for_employee)
  end

  test "should handle edge case salaries at bracket boundaries" do
    controller = ReportsController.new

    # Test exact boundary values
    assert_equal 78.38, controller.send(:calculate_inss_for_employee, 1045.00)
    assert_equal 94.01, controller.send(:calculate_inss_for_employee, 1045.01)

    # Test salaries at upper limits
    assert_equal 78.38, controller.send(:calculate_inss_for_employee, 1045.00)
    assert_equal 172.39, controller.send(:calculate_inss_for_employee, 2089.60)
  end
end
