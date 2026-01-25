# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

dummyjson = QuoteSource.find_or_create_by!(remote_path: "https://dummyjson.com/quotes/", quote_field: "quote", author_field: "author")
quoteshub = QuoteSource.find_or_create_by!(remote_path: "https://thequoteshub.com/api/quotes/", quote_field: "text", author_field: "author")

if Rails.env.development? || Rails.env.production?
  dummyjson.generate_quote_embeddings("DummyJSON", "https://dummyjson.com/quotes?limit=0")
  quoteshub.generate_quote_embeddings("The Quotes Hub", "https://thequoteshub.com/api/quotes?page=1&page_size=1500&format=json")
end
