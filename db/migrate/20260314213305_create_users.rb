class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.string :provider
      t.string :uid
      t.string :avatar_url
      t.datetime :last_login_at
      t.datetime :last_login_at_prev

      t.timestamps
    end
  end
end
