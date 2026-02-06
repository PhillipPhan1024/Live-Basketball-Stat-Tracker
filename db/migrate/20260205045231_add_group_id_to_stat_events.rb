class AddGroupIdToStatEvents < ActiveRecord::Migration[8.1]
  def change
    add_column :stat_events, :group_id, :string
    add_index :stat_events, :group_id
  end
end
