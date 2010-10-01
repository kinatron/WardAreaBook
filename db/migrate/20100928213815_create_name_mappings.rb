class CreateNameMappings < ActiveRecord::Migration
  def self.up
    create_table :name_mappings do |t|
      t.string :name
      t.string :category
      t.integer :person_id
      t.integer :family_id

      t.timestamps
    end
  end

  def self.down
    drop_table :name_mappings
  end
end
