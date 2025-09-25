class CreateContacts < ActiveRecord::Migration[8.0]
  def change
    create_table :contacts do |t|
      t.string :contact_type
      t.string :contact_content
      t.references :employee, null: false, foreign_key: true

      t.timestamps
    end
  end
end
