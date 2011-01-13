class CreateWardProfiles < ActiveRecord::Migration
  def self.up
    create_table :ward_profiles do |t|
      t.date :quarter
      t.integer :total_families
      t.integer :active
      t.integer :less_active
      t.integer :unknown
      t.integer :not_interested
      t.integer :dnc
      t.integer :new
      t.integer :moved
      t.integer :visited

      t.timestamps
    end
  end

  def self.down
    drop_table :ward_profiles
  end
end
