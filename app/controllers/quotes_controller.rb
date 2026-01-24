class QuotesController < ApplicationController
  before_action :set_httpx

  # GET /quotes/{:id}
  def show
    quote = Quote.find(params.expect(:id))

    process_and_render(quote)
  end

  # GET /quotes/random
  def random
    quote = Quote.find(Quote.pluck(:id).sample)

    process_and_render(quote)
  end

  private
    def process_and_render(quote)
      response = @http.get(quote.remote_uri)
      json = JSON.parse(response.body)

      json["id"] = quote.id
      json["remote_uri"] = quote.remote_uri

      similar = quote.nearest_neighbors(:embedding, distance: "cosine").first(5)
      json["similar_quotes"] = similar.map { |q| url_for(q) }

      render json: json
    end

    def set_httpx
      @http = HTTPX.with(headers: { 'accept': 'application/json', 'Content-Type': 'application/json' })
    end
end
