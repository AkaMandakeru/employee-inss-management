class AddSalaryDiscountToEmployess < ActiveRecord::Migration[8.0]
  def change
    add_column :employees, :salary_discount, :decimal
  end
end
