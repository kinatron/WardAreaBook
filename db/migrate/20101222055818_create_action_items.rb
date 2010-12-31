class CreateActionItems < ActiveRecord::Migration
  def self.up
    create_table :action_items do |t|
      t.integer :family_id
      t.integer :person_id
      t.integer :issuer_id
      t.text :action
      t.date :due_date
      t.string :status, :default => "open"
      t.text :comment

      t.timestamps
    end
  end

  def self.down
    drop_table :action_items
  end
end

