class CreateQuoteSource < ActiveRecord::Migration[8.1]
  def change
    create_table :quote_sources do |t|
      t.string :remote_path
      t.string :quote_field
      t.string :author_field

      t.timestamps
    end
  end
end
