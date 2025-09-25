require "test_helper"

class ContactTest < ActiveSupport::TestCase
  def setup
    @employee = Employee.create!(
      name: "John Doe",
      document: "12345678901",
      salary: 3000.00,
      employee_type: "employee",
      birthdate: Date.new(1990, 1, 1)
    )

    @contact = Contact.new(
      contact_type: "phone",
      contact_content: "123-456-7890",
      employee: @employee
    )
  end

  test "should be valid with valid attributes" do
    assert @contact.valid?
  end

  test "should belong to employee" do
    assert_equal @employee, @contact.employee
  end

  test "should be destroyed when employee is destroyed" do
    @contact.save
    assert_difference 'Contact.count', -1 do
      @employee.destroy
    end
  end

  test "should save with valid contact types" do
    valid_types = ["phone", "email", "mobile", "fax", "other"]

    valid_types.each do |type|
      @contact.contact_type = type
      @contact.contact_content = "test content for #{type}"

      assert @contact.valid?, "#{type} should be valid"
    end
  end

  test "should save with valid contact content" do
    valid_contents = [
      "123-456-7890",
      "test@example.com",
      "+55 11 99999-9999",
      "555-0123"
    ]

    valid_contents.each do |content|
      @contact.contact_content = content

      assert @contact.valid?, "#{content} should be valid"
    end
  end

  test "should allow blank contact type and content" do
    @contact.contact_type = ""
    @contact.contact_content = ""

    # Contact should still be valid as it might be optional
    assert @contact.valid?
  end

  test "should save successfully" do
    assert_difference 'Contact.count', 1 do
      @contact.save
    end

    saved_contact = Contact.last
    assert_equal "phone", saved_contact.contact_type
    assert_equal "123-456-7890", saved_contact.contact_content
    assert_equal @employee, saved_contact.employee
  end
end
