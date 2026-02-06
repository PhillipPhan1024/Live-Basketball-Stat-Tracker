class AddShootingStatsToPlayers < ActiveRecord::Migration[8.1]
  def change
    add_column :players, :three_pa, :integer, default: 0
    add_column :players, :three_pm, :integer, default: 0
    add_column :players, :fta, :integer, default: 0
    add_column :players, :ftm, :integer, default: 0
  end
end
