class AddLastActionGidToPlayers < ActiveRecord::Migration[8.1]
  def change
    add_column :players, :last_action_gid, :string
  end
end
