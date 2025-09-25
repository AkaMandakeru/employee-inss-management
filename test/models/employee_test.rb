require "test_helper"

class EmployeeTest < ActiveSupport::TestCase
  def setup
    @employee = Employee.new(
      name: "John Doe",
      document: "12345678901",
      salary: 3000.00,
      employee_type: "employee",
      birthdate: Date.new(1990, 1, 1)
    )
  end

  test "should be valid with valid attributes" do
    assert @employee.valid?
  end

  test "should require name" do
    @employee.name = nil
    assert_not @employee.valid?
    assert_includes @employee.errors[:name], "can't be blank"
  end

  test "should require name with minimum length" do
    @employee.name = "A"
    assert_not @employee.valid?
    assert_includes @employee.errors[:name], "is too short (minimum is 2 characters)"
  end

  test "should require document" do
    @employee.document = nil
    assert_not @employee.valid?
    assert_includes @employee.errors[:document], "can't be blank"
  end

  test "should require unique document" do
    duplicate_employee = @employee.dup
    @employee.save
    assert_not duplicate_employee.valid?
    assert_includes duplicate_employee.errors[:document], "has already been taken"
  end

  test "should require salary" do
    @employee.salary = nil
    assert_not @employee.valid?
    assert_includes @employee.errors[:salary], "can't be blank"
  end

  test "should require positive salary" do
    @employee.salary = 0
    assert_not @employee.valid?
    assert_includes @employee.errors[:salary], "must be greater than 0"

    @employee.salary = -100
    assert_not @employee.valid?
    assert_includes @employee.errors[:salary], "must be greater than 0"
  end

  test "should require employee_type" do
    @employee.employee_type = nil
    assert_not @employee.valid?
    assert_includes @employee.errors[:employee_type], "can't be blank"
  end

  test "should accept valid employee types" do
    valid_types = %w[employee domestic_employee worker]

    valid_types.each do |type|
      @employee.employee_type = type
      assert @employee.valid?, "#{type} should be valid"
    end
  end

  test "should not accept invalid employee type" do
    @employee.employee_type = "invalid_type"
    assert_not @employee.valid?
  end

  test "should have many addresses" do
    @employee.save
    address1 = @employee.addresses.build(street: "123 Main St", city: "Test City")
    address2 = @employee.addresses.build(street: "456 Oak Ave", city: "Test City")

    assert_difference '@employee.addresses.count', 2 do
      @employee.save
    end
  end

  test "should have many contacts" do
    @employee.save
    contact1 = @employee.contacts.build(contact_type: "phone", contact_content: "123-456-7890")
    contact2 = @employee.contacts.build(contact_type: "email", contact_content: "test@example.com")

    assert_difference '@employee.contacts.count', 2 do
      @employee.save
    end
  end

  test "should destroy dependent addresses when employee is destroyed" do
    @employee.save
    address = @employee.addresses.create!(street: "123 Main St", city: "Test City")

    assert_difference 'Address.count', -1 do
      @employee.destroy
    end
  end

  test "should destroy dependent contacts when employee is destroyed" do
    @employee.save
    contact = @employee.contacts.create!(contact_type: "phone", contact_content: "123-456-7890")

    assert_difference 'Contact.count', -1 do
      @employee.destroy
    end
  end

  test "should accept nested attributes for addresses" do
    @employee.addresses_attributes = {
      "0" => {
        street: "123 Main St",
        city: "Test City",
        state: "TS",
        zipcode: "12345"
      }
    }

    assert_difference '@employee.addresses.count', 1 do
      @employee.save
    end
  end

  test "should accept nested attributes for contacts" do
    @employee.contacts_attributes = {
      "0" => {
        contact_type: "phone",
        contact_content: "123-456-7890"
      }
    }

    assert_difference '@employee.contacts.count', 1 do
      @employee.save
    end
  end

  test "should reject blank nested attributes" do
    @employee.addresses_attributes = {
      "0" => {
        street: "",
        city: "",
        state: "",
        zipcode: ""
      }
    }

    assert_no_difference '@employee.addresses.count' do
      @employee.save
    end
  end

  test "should have correct enum values" do
    assert_equal 1, Employee.employee_types[:employee]
    assert_equal 2, Employee.employee_types[:domestic_employee]
    assert_equal 3, Employee.employee_types[:worker]
  end

  test "should respond to employee type predicate methods" do
    @employee.employee_type = "employee"
    assert @employee.employee?
    assert_not @employee.domestic_employee?
    assert_not @employee.worker?

    @employee.employee_type = "domestic_employee"
    assert_not @employee.employee?
    assert @employee.domestic_employee?
    assert_not @employee.worker?

    @employee.employee_type = "worker"
    assert_not @employee.employee?
    assert_not @employee.domestic_employee?
    assert @employee.worker?
  end

  test "should have TYPES constant" do
    expected_types = %w[employee domestic_employee worker]
    assert_equal expected_types, Employee::TYPES
  end
end
