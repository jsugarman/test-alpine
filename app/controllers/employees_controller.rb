class EmployeesController < ApplicationController
  def index
    @employees = Employee.all
  end

  def show
    @employee = Employee.find(params[:id])
  end

  def new
    @employee = Employee.new
  end

  def create
    @employee = Employee.new(employee_params)
    if @employee.save
      flash[:success] = "Employee created!"
      redirect_to action: :show, id: @employee.id
    else
      flash[:error] = "Employee creation failed!"
      render action: :new
    end
  end

  def edit
    @employee = Employee.find(params[:id])
  end

  def update
    @employee = Employee.find(params[:id])
    if @employee.update_attributes(employee_params)
      flash[:success] = "Employee update!"
      redirect_to action: :show, id: @employee.id
     else
      flash[:error] = "Employee update failed!"
      render action: :edit
    end
  end

  def destroy
    @employee = Employee.find(params[:id])
    if @employee.destroy
      flash[:success] = "Employee deleted!"
      redirect_to action: :index
     else
      flash[:error] = "Employee not deleted!"
      render action: :index
    end
  end

  private

  def employee_params
    params.require(:employee).permit(:first_name, :last_name, :age, :dob)
  end
end
