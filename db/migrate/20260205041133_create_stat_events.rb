class CreateStatEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :stat_events do |t|
      t.references :player, null: false, foreign_key: true
      t.string :action, null: false
      t.integer :value, default: 1

      t.timestamps
    end
  end
end
