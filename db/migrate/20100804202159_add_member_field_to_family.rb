class AddMemberFieldToFamily < ActiveRecord::Migration
  def self.up
    add_column :families, :member, :boolean, :default => true
  end

  def self.down
    remove_column :families, :member 
  end
end
