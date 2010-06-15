class CreateWardRepresentatives < ActiveRecord::Migration
  def self.up
    create_table :ward_representatives do |t|
      t.string :name
      t.string :type

      t.timestamps
    end
  end

  def self.down
    drop_table :ward_representatives
  end
end
