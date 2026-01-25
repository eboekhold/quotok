class QuoteSource < ApplicationRecord
  validates :remote_path, presence: true, uniqueness: true
  validates :quote_field, presence: true
  validates :author_field, presence: true

  has_many :quotes

  def generate_quote_embeddings(name, quotes_path)
    http = HTTPX.with(headers: { 'accept': "application/json", 'Content-Type': "application/json" })

    puts "Requesting all quotes from #{name}" unless Rails.env.test?
    response = http.get(quotes_path)
    json = JSON.parse(response.body)

    external_quote_objects = json["quotes"]

    quote_texts = external_quote_objects.map { |q| q[quote_field] }

    puts "Generating embeddings on quotes through OpenAI" unless Rails.env.test?
    embeddings = RubyLLM.embed(quote_texts).vectors

    puts "Saving quotes to the database" unless Rails.env.test?
    Quote.transaction do
      external_quote_objects.each_with_index do |external_quote_object, index|
        external_id = external_quote_object["id"]
        Quote.create!(
          quote_source: self,
          remote_id: external_id,
          embedding: embeddings[index]
        )
      end
    end
  end
end
