class QuotesController < ApplicationController
  # GET /quotes/{:id}
  def show
    quote = Quote.find(params.expect(:id))

    response = remote_quote(quote)

    render json: prepare_json(response, quote), status: response.status
  end

  # GET /quotes/random
  def random
    quote = Quote.find(Quote.pluck(:id).sample)

    response = remote_quote(quote)

    render json: prepare_json(response, quote), status: response.status
  end

  private
    def remote_quote(quote)
      http = HTTPX.with(headers: { 'accept': "application/json", 'Content-Type': "application/json" })

      http.get(quote.remote_uri)
    end

    def prepare_json(response, quote)
      quote_source = quote.quote_source

      remote_json = JSON.parse(response.body)

      json = {}

      json["id"] = quote.id
      json["remote_uri"] = quote.remote_uri

      similar = quote.nearest_neighbors(:embedding, distance: "cosine").first(5)
      json["similar_quotes"] = similar.map { |similar_quote| url_for(similar_quote) }

      if response.status == 200
        json["quote"] = remote_json[quote_source.quote_field]
        json["author"] = remote_json[quote_source.author_field]
      else
        json["remote_error"] = remote_json
      end

      json
    end
end
