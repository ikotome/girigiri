class CreateEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :events do |t|
      t.string :title
      t.integer :category
      t.string :source_url
      t.string :organizer
      t.date :event_at
      t.text :notes
      t.boolean :is_personal

      t.timestamps
    end
  end
end
