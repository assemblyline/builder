class CreateCustomers < ActiveRecord::Migration
  def change
    create_table :customers do |t|
      t.string :name
      t.integer :age
      t.boolean :awesome

      t.timestamps null: false
    end
  end
end
