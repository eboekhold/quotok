class AddQuoteSourceToQuotes < ActiveRecord::Migration[8.1]
  def up
    dummyjson_source = QuoteSource.find_or_create_by!(remote_path: "https://dummyjson.com/quotes/", quote_field: "quote", author_field: "author")
    thequoteshub_source = QuoteSource.find_or_create_by!(remote_path: "https://thequoteshub.com/api/quotes/", quote_field: "text", author_field: "author")

    add_reference :quotes, :quote_source
    rename_column :quotes, :remote_uri, :remote_id

    change_column_null :quotes, :remote_id, false

    Quote.find_each do |quote|
      if quote.remote_id.include? "dummyjson"
        quote.quote_source = dummyjson_source
      elsif quote.remote_id.include? "thequoteshub"
        quote.quote_source = thequoteshub_source
      else
        raise "Unknown quote source."
      end

      quote.remote_id = quote.remote_id.sub(quote.quote_source.remote_path, "")

      quote.save!
    end

    change_column_null :quotes, :quote_source_id, false
  end

  def down
    Quote.find_each do |quote|
      quote.remote_id = "#{quote.quote_source.remote_path}#{quote.remote_id}"

      quote.save!
    end

    change_column_null :quotes, :remote_id, true

    rename_column :quotes, :remote_id, :remote_uri
    remove_reference :quotes, :quote_source
  end
end
