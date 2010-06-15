class ChangeEventColumnMember < ActiveRecord::Migration
  def self.up
    change_column :events, :member, :integer
    rename_column :events, :member, :ward_representative_id
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
