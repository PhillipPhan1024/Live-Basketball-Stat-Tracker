class AddBlocksAndStealsToPlayers < ActiveRecord::Migration[8.1]
  def change
    add_column :players, :blocks, :integer, default: 0
    add_column :players, :steals, :integer, default: 0
  end
end
