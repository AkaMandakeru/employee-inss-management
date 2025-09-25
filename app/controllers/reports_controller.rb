class ReportsController < ApplicationController
  def index
    @employees_count = Employee.count
    @total_salary = Employee.sum(:salary) || 0
    @average_salary = Employee.average(:salary) || 0

    # Salary bracket analysis based on INSS calculation
    @salary_brackets = calculate_salary_brackets
    @bracket_statistics = calculate_bracket_statistics
    @recent_employees = Employee.order(created_at: :desc).limit(5)

    # Chart data for Stimulus controller
    @salary_brackets_data = prepare_salary_brackets_chart_data
    @inss_distribution_data = prepare_inss_distribution_chart_data
  end

  helper_method :calculate_inss_for_employee

  private

  def calculate_salary_brackets
    brackets = {
      'bracket_1' => { min: 0, max: 1045.00, rate: 0.075, employees: [] },
      'bracket_2' => { min: 1045.01, max: 2089.60, rate: 0.09, employees: [] },
      'bracket_3' => { min: 2089.61, max: 3134.40, rate: 0.12, employees: [] },
      'bracket_4' => { min: 3134.41, max: 6101.06, rate: 0.14, employees: [] }
    }

    Employee.includes(:addresses, :contacts).each do |employee|
      salary = employee.salary.to_f

      case salary
      when 0..1045.00
        brackets['bracket_1'][:employees] << employee
      when 1045.01..2089.60
        brackets['bracket_2'][:employees] << employee
      when 2089.61..3134.40
        brackets['bracket_3'][:employees] << employee
      when 3134.41..6101.06
        brackets['bracket_4'][:employees] << employee
      end
    end

    brackets
  end

  def calculate_bracket_statistics
    stats = {}

    @salary_brackets.each do |key, bracket|
      employees = bracket[:employees]
      count = employees.count

      stats[key] = {
        count: count,
        percentage: @employees_count > 0 ? (count.to_f / @employees_count * 100).round(1) : 0,
        total_salary: employees.sum(&:salary),
        average_salary: count > 0 ? (employees.sum(&:salary) / count).round(2) : 0,
        total_inss: employees.sum { |emp| calculate_inss_for_employee(emp.salary.to_f) },
        average_inss: count > 0 ? (employees.sum { |emp| calculate_inss_for_employee(emp.salary.to_f) } / count).round(2) : 0
      }
    end

    stats
  end

  def calculate_inss_for_employee(salary)
    # Same logic as in the Stimulus controller
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

  def prepare_salary_brackets_chart_data
    {
      labels: ['1st Bracket\n(≤ R$ 1.045)', '2nd Bracket\n(R$ 1.045 - R$ 2.089)', '3rd Bracket\n(R$ 2.089 - R$ 3.134)', '4th Bracket\n(R$ 3.134 - R$ 6.101)'],
      datasets: [{
        label: 'Number of Employees',
        data: [
          @bracket_statistics['bracket_1'][:count],
          @bracket_statistics['bracket_2'][:count],
          @bracket_statistics['bracket_3'][:count],
          @bracket_statistics['bracket_4'][:count]
        ],
        backgroundColor: ['#FF6384', '#36A2EB', '#FFCE56', '#4BC0C0'],
        borderColor: ['#FF6384', '#36A2EB', '#FFCE56', '#4BC0C0'],
        borderWidth: 1
      }]
    }
  end

  def prepare_inss_distribution_chart_data
    {
      labels: ['1st Bracket', '2nd Bracket', '3rd Bracket', '4th Bracket'],
      datasets: [{
        label: 'Total INSS (R$)',
        data: [
          @bracket_statistics['bracket_1'][:total_inss],
          @bracket_statistics['bracket_2'][:total_inss],
          @bracket_statistics['bracket_3'][:total_inss],
          @bracket_statistics['bracket_4'][:total_inss]
        ],
        backgroundColor: ['#FF6384', '#36A2EB', '#FFCE56', '#4BC0C0'],
        borderColor: ['#FF6384', '#36A2EB', '#FFCE56', '#4BC0C0'],
        borderWidth: 1
      }]
    }
  end
end
