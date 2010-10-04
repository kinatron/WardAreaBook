class CreateCallings < ActiveRecord::Migration
  def self.up
    create_table :callings do |t|
      t.string :job
      t.integer :person_id
      t.integer :access_level, :default => 0

      t.timestamps
    end
  end

  def self.down
    drop_table :callings
  end
end
