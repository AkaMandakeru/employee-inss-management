class EmployeesController < ApplicationController
  before_action :set_employee, only: [:show, :edit, :update, :destroy]

  def index
    @employees = Employee.includes(:addresses, :contacts).paginate(page: params[:page], per_page: 10)
  end

  def show
    @employee = Employee.includes(:addresses, :contacts).find(params[:id])
  end

  def new
    @employee = Employee.new
    @employee.addresses.build
    3.times { @employee.contacts.build }
  end

  def create
    @employee = Employee.new(employee_params)

    if @employee.save
      redirect_to employees_path, notice: 'Employee was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @employee.addresses.build if @employee.addresses.empty?
    # Build additional contacts up to 3 total
    while @employee.contacts.length < 3
      @employee.contacts.build
    end
  end

  def update
    if @employee.update(employee_params)
      redirect_to employees_path, notice: 'Employee was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @employee.destroy
    redirect_to employees_path, notice: 'Employee was successfully deleted.'
  end

  private

  def set_employee
    @employee = Employee.find(params[:id])
  end

  def employee_params
    params.require(:employee).permit(
      :employee_type, :name, :birthdate, :document, :salary, :salary_discount,
      addresses_attributes: [:id, :street, :number, :city, :state, :zipcode, :complement, :neighborhood, :status, :_destroy],
      contacts_attributes: [:id, :contact_type, :contact_content, :_destroy]
    )
  end
end
