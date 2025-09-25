class CreateEmployees < ActiveRecord::Migration[8.0]
  def change
    create_table :employees do |t|
      t.integer :employee_type
      t.string :name
      t.date :birthdate
      t.string :document
      t.decimal :salary

      t.timestamps
    end
  end
end
