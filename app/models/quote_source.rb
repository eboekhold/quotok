class QuoteSource < ApplicationRecord
  validates :remote_path, presence: true, uniqueness: true
  validates :quote_field, presence: true
  validates :author_field, presence: true

  has_many :quotes

  def generate_quote_embeddings(name, quotes_path)
    http = HTTPX.with(headers: { 'accept': "application/json", 'Content-Type': "application/json" })

    puts "Requesting all quotes from #{name}" unless Rails.env.test?
    response = http.get(quotes_path)

    unless response.error
      json = JSON.parse(response.body)

      external_quote_objects = json["quotes"]

      quote_texts = external_quote_objects.map { |q| q[quote_field] }
    else
      logger.error error_text(response)

      return false
    end

    puts "Generating embeddings on quotes through OpenAI" unless Rails.env.test?
    begin
      embeddings = RubyLLM.embed(quote_texts).vectors
    rescue RubyLLM::Error => e
      logger.error "RubyLLM API Error: #{e.class} - #{e.message}"

      return false
    end

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

  private
    def error_text(response)
      if response.try(:body).present?
        JSON.parse(response.body)
      else
        response.error.message
      end
    end
end
