class CreateDeadlines < ActiveRecord::Migration[8.1]
  def change
    create_table :deadlines do |t|
      t.references :event, null: false, foreign_key: true
      t.date :deadline_at
      t.string :label
      t.datetime :changed_at
      t.date :deadline_at_prev

      t.timestamps
    end
  end
end
