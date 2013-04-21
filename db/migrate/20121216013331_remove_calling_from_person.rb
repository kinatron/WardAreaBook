class RemoveCallingFromPerson < ActiveRecord::Migration
  def up
    remove_column :people, :calling
  end

  def down
    add_column :people, :calling, :string
  end
end
