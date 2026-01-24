class CreateQuotes < ActiveRecord::Migration[8.1]
  def change
    create_table :quotes do |t|
      t.text :uri
      t.vector :embedding, limit: 1536

      t.timestamps
    end
  end
end
