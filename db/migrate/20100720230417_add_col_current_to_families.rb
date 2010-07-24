class AddColCurrentToFamilies < ActiveRecord::Migration
  def self.up
    add_column :families, :current, :boolean, :default => true
  end

  def self.down
    remove_column :families, :current
  end
end
