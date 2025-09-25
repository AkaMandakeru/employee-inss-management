class ReportsController < ApplicationController
  def index
    @employees_count = Employee.count
    @total_salary = Employee.sum(:salary) || 0
    @average_salary = Employee.average(:salary) || 0
  end
end
