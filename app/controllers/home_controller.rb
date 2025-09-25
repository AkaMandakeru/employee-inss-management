class HomeController < ApplicationController
  def index
    @employees = Employee.includes(:addresses, :contacts).paginate(page: params[:page], per_page: 10)
    @total_employees = Employee.count
  end
end
