class ChangeColTypeToCagetory < ActiveRecord::Migration
  def self.up
    rename_column :ward_representatives, :type, :category
  end

  def self.down
    rename_column :ward_representatives, :category, :type
  end
end
