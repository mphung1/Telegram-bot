class CreateBots < ActiveRecord::Migration[7.0]
  def change
    create_table :bots do |t|
      t.string :username
      t.string :description
      t.string :user
      t.string :references

      t.timestamps
    end
  end
end
