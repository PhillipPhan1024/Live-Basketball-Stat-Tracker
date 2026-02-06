class CreatePlayers < ActiveRecord::Migration[8.1]
  def change
    create_table :players do |t|
      t.string :name, null: false
      t.integer :points, default: 0
      t.integer :fga, default: 0
      t.integer :fgm, default: 0
      t.integer :rebounds, default: 0
      t.integer :turnovers, default: 0

      t.timestamps
    end
  end
end
