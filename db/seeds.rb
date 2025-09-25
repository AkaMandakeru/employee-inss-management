# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Clear existing data
puts "Clearing existing data..."
Employee.destroy_all
User.destroy_all

# Create a default admin user
puts "Creating admin user..."
admin_user = User.create!(
  email_address: "admin@credishop.com",
  password: "admin123",
  password_confirmation: "admin123"
)

# Employee data with realistic Brazilian names and information
employees_data = [
  {
    name: "João Silva Santos",
    document: "12345678901",
    birthdate: Date.new(1985, 3, 15),
    salary: 2800.00,
    employee_type: "employee",
    address: {
      street: "Rua das Flores, 123",
      number: "123",
      city: "São Paulo",
      state: "SP",
      zipcode: "01234-567",
      neighborhood: "Centro",
      complement: "Apto 45",
      status: 1
    },
    contacts: [
      { contact_type: "phone", contact_content: "(11) 99999-1234" },
      { contact_type: "email", contact_content: "joao.silva@email.com" },
      { contact_type: "mobile", contact_content: "(11) 98765-4321" }
    ]
  },
  {
    name: "Maria Oliveira Costa",
    document: "98765432100",
    birthdate: Date.new(1990, 7, 22),
    salary: 3200.00,
    employee_type: "employee",
    address: {
      street: "Avenida Paulista, 456",
      number: "456",
      city: "São Paulo",
      state: "SP",
      zipcode: "01310-100",
      neighborhood: "Bela Vista",
      complement: "Sala 201",
      status: 1
    },
    contacts: [
      { contact_type: "phone", contact_content: "(11) 3333-4444" },
      { contact_type: "email", contact_content: "maria.oliveira@email.com" }
    ]
  },
  {
    name: "Pedro Ferreira Lima",
    document: "11122233344",
    birthdate: Date.new(1988, 11, 8),
    salary: 1500.00,
    employee_type: "domestic_employee",
    address: {
      street: "Rua Augusta, 789",
      number: "789",
      city: "São Paulo",
      state: "SP",
      zipcode: "01305-000",
      neighborhood: "Consolação",
      complement: "Casa 2",
      status: 1
    },
    contacts: [
      { contact_type: "phone", contact_content: "(11) 5555-6666" },
      { contact_type: "mobile", contact_content: "(11) 94444-5555" }
    ]
  },
  {
    name: "Ana Paula Rodrigues",
    document: "55566677788",
    birthdate: Date.new(1992, 5, 30),
    salary: 4200.00,
    employee_type: "employee",
    address: {
      street: "Rua Oscar Freire, 321",
      number: "321",
      city: "São Paulo",
      state: "SP",
      zipcode: "01426-001",
      neighborhood: "Jardins",
      complement: "Apto 12",
      status: 1
    },
    contacts: [
      { contact_type: "phone", contact_content: "(11) 7777-8888" },
      { contact_type: "email", contact_content: "ana.rodrigues@email.com" },
      { contact_type: "mobile", contact_content: "(11) 96666-7777" }
    ]
  },
  {
    name: "Carlos Eduardo Souza",
    document: "99988877766",
    birthdate: Date.new(1983, 12, 12),
    salary: 1800.00,
    employee_type: "worker",
    address: {
      street: "Rua da Consolação, 654",
      number: "654",
      city: "São Paulo",
      state: "SP",
      zipcode: "01302-000",
      neighborhood: "Consolação",
      complement: "Fundos",
      status: 1
    },
    contacts: [
      { contact_type: "phone", contact_content: "(11) 2222-3333" },
      { contact_type: "mobile", contact_content: "(11) 98888-9999" }
    ]
  },
  {
    name: "Fernanda Almeida",
    document: "44455566677",
    birthdate: Date.new(1987, 9, 18),
    salary: 2600.00,
    employee_type: "employee",
    address: {
      street: "Alameda Santos, 987",
      number: "987",
      city: "São Paulo",
      state: "SP",
      zipcode: "01418-100",
      neighborhood: "Jardins",
      complement: "Apto 34",
      status: 1
    },
    contacts: [
      { contact_type: "phone", contact_content: "(11) 4444-5555" },
      { contact_type: "email", contact_content: "fernanda.almeida@email.com" }
    ]
  },
  {
    name: "Roberto Mendes",
    document: "77788899900",
    birthdate: Date.new(1981, 1, 25),
    salary: 1200.00,
    employee_type: "domestic_employee",
    address: {
      street: "Rua Vergueiro, 147",
      number: "147",
      city: "São Paulo",
      state: "SP",
      zipcode: "01504-000",
      neighborhood: "Liberdade",
      complement: "Casa",
      status: 1
    },
    contacts: [
      { contact_type: "phone", contact_content: "(11) 6666-7777" },
      { contact_type: "mobile", contact_content: "(11) 97777-8888" }
    ]
  },
  {
    name: "Juliana Barbosa",
    document: "33344455566",
    birthdate: Date.new(1994, 6, 14),
    salary: 3800.00,
    employee_type: "employee",
    address: {
      street: "Rua Haddock Lobo, 258",
      number: "258",
      city: "São Paulo",
      state: "SP",
      zipcode: "01414-000",
      neighborhood: "Jardins",
      complement: "Apto 67",
      status: 1
    },
    contacts: [
      { contact_type: "phone", contact_content: "(11) 8888-9999" },
      { contact_type: "email", contact_content: "juliana.barbosa@email.com" },
      { contact_type: "mobile", contact_content: "(11) 95555-6666" }
    ]
  },
  {
    name: "Marcos Antonio Pereira",
    document: "66677788899",
    birthdate: Date.new(1989, 4, 3),
    salary: 2200.00,
    employee_type: "worker",
    address: {
      street: "Rua São Bento, 369",
      number: "369",
      city: "São Paulo",
      state: "SP",
      zipcode: "01011-100",
      neighborhood: "Centro",
      complement: "Loja 15",
      status: 1
    },
    contacts: [
      { contact_type: "phone", contact_content: "(11) 1111-2222" },
      { contact_type: "mobile", contact_content: "(11) 93333-4444" }
    ]
  },
  {
    name: "Patricia Santos",
    document: "22233344455",
    birthdate: Date.new(1986, 8, 27),
    salary: 3400.00,
    employee_type: "employee",
    address: {
      street: "Rua dos Três Irmãos, 741",
      number: "741",
      city: "São Paulo",
      state: "SP",
      zipcode: "05615-190",
      neighborhood: "Vila Progredior",
      complement: "Casa 3",
      status: 1
    },
    contacts: [
      { contact_type: "phone", contact_content: "(11) 9999-0000" },
      { contact_type: "email", contact_content: "patricia.santos@email.com" },
      { contact_type: "mobile", contact_content: "(11) 92222-3333" }
    ]
  },
  {
    name: "Ricardo Fernandes",
    document: "88899900011",
    birthdate: Date.new(1991, 2, 19),
    salary: 1600.00,
    employee_type: "domestic_employee",
    address: {
      street: "Rua Fradique Coutinho, 852",
      number: "852",
      city: "São Paulo",
      state: "SP",
      zipcode: "05416-010",
      neighborhood: "Vila Madalena",
      complement: "Apto 23",
      status: 1
    },
    contacts: [
      { contact_type: "phone", contact_content: "(11) 5555-0000" },
      { contact_type: "mobile", contact_content: "(11) 91111-2222" }
    ]
  },
  {
    name: "Camila Ribeiro",
    document: "11100099988",
    birthdate: Date.new(1993, 10, 5),
    salary: 4500.00,
    employee_type: "employee",
    address: {
      street: "Rua dos Pinheiros, 963",
      number: "963",
      city: "São Paulo",
      state: "SP",
      zipcode: "05422-001",
      neighborhood: "Pinheiros",
      complement: "Apto 89",
      status: 1
    },
    contacts: [
      { contact_type: "phone", contact_content: "(11) 7777-0000" },
      { contact_type: "email", contact_content: "camila.ribeiro@email.com" },
      { contact_type: "mobile", contact_content: "(11) 94444-0000" }
    ]
  },
  {
    name: "Diego Carvalho",
    document: "44433322211",
    birthdate: Date.new(1984, 12, 31),
    salary: 1900.00,
    employee_type: "worker",
    address: {
      street: "Rua Harmonia, 147",
      number: "147",
      city: "São Paulo",
      state: "SP",
      zipcode: "05435-030",
      neighborhood: "Vila Madalena",
      complement: "Casa 5",
      status: 1
    },
    contacts: [
      { contact_type: "phone", contact_content: "(11) 3333-0000" },
      { contact_type: "mobile", contact_content: "(11) 90000-1111" }
    ]
  },
  {
    name: "Luciana Gomes",
    document: "77766655544",
    birthdate: Date.new(1988, 7, 16),
    salary: 3100.00,
    employee_type: "employee",
    address: {
      street: "Rua dos Patriotas, 258",
      number: "258",
      city: "São Paulo",
      state: "SP",
      zipcode: "05633-020",
      neighborhood: "Alto de Pinheiros",
      complement: "Apto 12",
      status: 1
    },
    contacts: [
      { contact_type: "phone", contact_content: "(11) 8888-1111" },
      { contact_type: "email", contact_content: "luciana.gomes@email.com" },
      { contact_type: "mobile", contact_content: "(11) 95555-0000" }
    ]
  },
  {
    name: "Thiago Nascimento",
    document: "00011122233",
    birthdate: Date.new(1995, 3, 8),
    salary: 2300.00,
    employee_type: "worker",
    address: {
      street: "Rua Cardeal Arcoverde, 369",
      number: "369",
      city: "São Paulo",
      state: "SP",
      zipcode: "05407-000",
      neighborhood: "Pinheiros",
      complement: "Fundos",
      status: 1
    },
    contacts: [
      { contact_type: "phone", contact_content: "(11) 2222-1111" },
      { contact_type: "mobile", contact_content: "(11) 93333-0000" }
    ]
  }
]

# Helper method to calculate INSS discount
def calculate_inss_discount(salary)
  brackets = [
    { min: 0, max: 1045.00, rate: 0.075 },
    { min: 1045.01, max: 2089.60, rate: 0.09 },
    { min: 2089.61, max: 3134.40, rate: 0.12 },
    { min: 3134.41, max: 6101.06, rate: 0.14 }
  ]

  total_discount = 0
  remaining_salary = salary

  brackets.each do |bracket|
    break if remaining_salary <= 0

    taxable_in_bracket = [remaining_salary, bracket[:max] - bracket[:min] + 0.01].min
    discount_in_bracket = taxable_in_bracket * bracket[:rate]

    total_discount += discount_in_bracket
    remaining_salary -= taxable_in_bracket

    break if remaining_salary <= 0
  end

  (total_discount * 100).round / 100.0
end

# Create employees with addresses and contacts
puts "Creating #{employees_data.length} employees..."

employees_data.each_with_index do |employee_data, index|
  puts "Creating employee #{index + 1}: #{employee_data[:name]}"

  # Calculate INSS discount
  salary_discount = calculate_inss_discount(employee_data[:salary])

  # Create employee
  employee = Employee.create!(
    name: employee_data[:name],
    document: employee_data[:document],
    birthdate: employee_data[:birthdate],
    salary: employee_data[:salary],
    salary_discount: salary_discount,
    employee_type: employee_data[:employee_type]
  )

  # Create address
  Address.create!(
    street: employee_data[:address][:street],
    number: employee_data[:address][:number],
    city: employee_data[:address][:city],
    state: employee_data[:address][:state],
    zipcode: employee_data[:address][:zipcode],
    neighborhood: employee_data[:address][:neighborhood],
    complement: employee_data[:address][:complement],
    status: employee_data[:address][:status],
    employee: employee
  )

  # Create contacts
  employee_data[:contacts].each do |contact_data|
    Contact.create!(
      contact_type: contact_data[:contact_type],
      contact_content: contact_data[:contact_content],
      employee: employee
    )
  end
end

puts "\n✅ Seed data created successfully!"
puts "📊 Summary:"
puts "   • #{User.count} user(s) created"
puts "   • #{Employee.count} employee(s) created"
puts "   • #{Address.count} address(es) created"
puts "   • #{Contact.count} contact(s) created"
puts "\n💰 Salary Distribution:"
puts "   • Regular Employees: #{Employee.where(employee_type: 'employee').count}"
puts "   • Domestic Employees: #{Employee.where(employee_type: 'domestic_employee').count}"
puts "   • Workers: #{Employee.where(employee_type: 'worker').count}"
puts "   • Total Payroll: R$ #{Employee.sum(:salary).round(2)}"
puts "   • Average Salary: R$ #{Employee.average(:salary).round(2)}"
puts "\n🔐 Admin Login:"
puts "   • Email: admin@credishop.com"
puts "   • Password: admin123"
