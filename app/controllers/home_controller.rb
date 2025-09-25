class HomeController < ApplicationController
  def index
    @employees = Employee.includes(:addresses, :contacts).limit(10)
    @total_employees = Employee.count
  end
end
