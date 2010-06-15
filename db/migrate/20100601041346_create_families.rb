class CreateFamilies < ActiveRecord::Migration
  def self.up
    create_table :families do |t|
      t.string :name
      t.string :head_of_house_hold
      t.string :phone
      t.string :address
      t.string :status
      t.text :information

      t.timestamps
    end
  end

  def self.down
    drop_table :families
  end
end
