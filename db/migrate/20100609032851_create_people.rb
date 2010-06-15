class CreatePeople < ActiveRecord::Migration
  def self.up
    create_table :people do |t|
      t.string :name
      t.integer :family_id
      t.string :phone
      t.string :email
      t.string :calling

      t.timestamps
    end
  end

  def self.down
    drop_table :people
  end
end
