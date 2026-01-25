class QuotesController < ApplicationController
  # GET /quotes/{:id}
  def show
    quote = Quote.find(params.expect(:id))

    remote_json = remote_quote(quote)

    render json: prepare_json(remote_json, quote)
  end

  # GET /quotes/random
  def random
    quote = Quote.find(Quote.pluck(:id).sample)

    remote_json = remote_quote(quote)

    render json: prepare_json(remote_json, quote)
  end

  private
    def remote_quote(quote)
      http = HTTPX.with(headers: { 'accept': "application/json", 'Content-Type': "application/json" })

      response = http.get(quote.remote_uri)

      JSON.parse(response.body)
    end

    def prepare_json(remote_json, quote)
      quote_source = quote.quote_source

      json = {}

      json["id"] = quote.id
      json["quote"] = remote_json[quote_source.quote_field]
      json["author"] = remote_json[quote_source.author_field]
      json["remote_uri"] = quote.remote_uri

      similar = quote.nearest_neighbors(:embedding, distance: "cosine").first(5)
      json["similar_quotes"] = similar.map { |similar_quote| url_for(similar_quote) }

      json
    end
end
