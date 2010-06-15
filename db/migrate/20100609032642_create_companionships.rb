class CreateCompanionships < ActiveRecord::Migration
  def self.up
    create_table :companionships do |t|
      t.string :type
      t.integer :person1
      t.integer :person2

      t.timestamps
    end
  end

  def self.down
    drop_table :companionships
  end
end
