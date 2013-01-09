class RemovePersonIdFromCalling < ActiveRecord::Migration
  def up
    remove_column :callings, :person_id
  end

  def down
    add_column :callings, :person_id, :integer
  end
end
