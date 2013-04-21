class AddUidToPerson < ActiveRecord::Migration
  def change
    add_column :people, :uid, :string
  end
end
