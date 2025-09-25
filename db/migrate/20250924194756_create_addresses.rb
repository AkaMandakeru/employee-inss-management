class CreateAddresses < ActiveRecord::Migration[8.0]
  def change
    create_table :addresses do |t|
      t.string :street
      t.string :number
      t.string :city
      t.string :state
      t.string :zipcode
      t.integer :status
      t.string :complement
      t.string :neighborhood

      t.references :employee, null: false, foreign_key: true

      t.timestamps
    end
  end
end
