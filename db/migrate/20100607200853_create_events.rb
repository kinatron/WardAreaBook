class CreateEvents < ActiveRecord::Migration
  def self.up
    create_table :events do |t|
      t.date :date
      t.integer :family_id
      t.string :member
      t.text :comment

      t.timestamps
    end
  end

  def self.down
    drop_table :events
  end
end
