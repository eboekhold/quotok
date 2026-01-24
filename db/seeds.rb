# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

if Rails.env.development? || Rails.env.production?
  http = HTTPX.with(headers: { 'accept': 'application/json', 'Content-Type': 'application/json' })

  puts "Requesting all quotes from dummyjson.com"
  response = http.get("https://dummyjson.com/quotes?limit=0")
  json = JSON.parse(response.body)

  external_quote_objects = json["quotes"]

  quote_texts = external_quote_objects.map { |q| q["quote"] }

  puts "Generating embeddings on quotes through OpenAI"
  embeddings = RubyLLM.embed(quote_texts).vectors

  puts "Saving quote URIs and embeddings to database"
  Quote.transaction do
    external_quote_objects.each_with_index do |external_quote_object, index|
      external_id = external_quote_object["id"]
      quote = Quote.new(
        remote_uri: "https://dummyjson.com/quotes/#{external_id}",
        embedding: embeddings[index]
      ).save!
    end
  end
end
