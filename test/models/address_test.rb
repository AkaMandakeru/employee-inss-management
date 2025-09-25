require "test_helper"

class AddressTest < ActiveSupport::TestCase
  def setup
    @employee = Employee.create!(
      name: "John Doe",
      document: "12345678901",
      salary: 3000.00,
      employee_type: "employee",
      birthdate: Date.new(1990, 1, 1)
    )

    @address = Address.new(
      street: "123 Main St",
      number: "456",
      city: "Test City",
      state: "TS",
      zipcode: "12345",
      neighborhood: "Downtown",
      complement: "Apt 101",
      addressable: @employee
    )
  end

  test "should be valid with valid attributes" do
    assert @address.valid?
  end

  test "should belong to addressable (polymorphic)" do
    assert_equal @employee, @address.addressable
  end

  test "should be destroyed when employee is destroyed" do
    @address.save
    assert_difference 'Address.count', -1 do
      @employee.destroy
    end
  end

  test "should allow blank fields" do
    @address.street = ""
    @address.city = ""
    @address.state = ""

    # Address should still be valid as it might be optional
    assert @address.valid?
  end

  test "should save with all fields populated" do
    assert_difference 'Address.count', 1 do
      @address.save
    end

    saved_address = Address.last
    assert_equal "123 Main St", saved_address.street
    assert_equal "456", saved_address.number
    assert_equal "Test City", saved_address.city
    assert_equal "TS", saved_address.state
    assert_equal "12345", saved_address.zipcode
    assert_equal "Downtown", saved_address.neighborhood
    assert_equal "Apt 101", saved_address.complement
    assert_equal @employee, saved_address.addressable
  end
end
