class CreateCallingAssignments < ActiveRecord::Migration
  def change
    create_table :calling_assignments do |t|
      t.integer :calling_id
      t.integer :person_id

      t.timestamps
    end
    add_index :calling_assignments, :calling_id
    add_index :calling_assignments, :person_id
    add_index :calling_assignments, [:calling_id, :person_id], :unique => true
  end
end
