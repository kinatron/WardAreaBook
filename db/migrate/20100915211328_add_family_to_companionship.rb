class AddFamilyToCompanionship < ActiveRecord::Migration
  def self.up
    add_column :companionships, :family_id, :integer
    rename_column :companionships, :person1, :person_id
    remove_column :companionships, :person2
    rename_column :companionships, :type, :category
    rename_table :companionships, :teaching_routes
  end

  def self.down
    remove_column :companionships, :family_id
    rename_column :companionships, :category, :type
  end
end
