class AddPublicIdToPlayers < ActiveRecord::Migration[8.1]
  def change
    add_column :players, :public_id, :string
    add_index :players, :public_id, unique: true
  end
end
