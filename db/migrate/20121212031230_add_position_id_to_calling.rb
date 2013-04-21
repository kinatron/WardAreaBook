class AddPositionIdToCalling < ActiveRecord::Migration
  def change
    add_column :callings, :position_id, :string
  end
end
