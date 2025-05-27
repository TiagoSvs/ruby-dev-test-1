class CreateDirectories < ActiveRecord::Migration[8.0]
  def change
    create_table :directories do |t|
      t.string :name, null: false
      t.references :directory, foreign_key: { to_table: :directories }, null: true

      t.timestamps
    end

    add_index :directories, [:directory_id, :name], unique: true
  end
end
