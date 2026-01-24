class QuotesController < ApplicationController
  # GET /quotes/{:id}
  def show
    http = HTTPX.with(headers: { 'accept': 'application/json', 'Content-Type': 'application/json' })

    @quote = Quote.find(params.expect(:id))

    response = http.get(@quote.remote_uri)
    json = JSON.parse(response.body)

    json["id"] = @quote.id
    json["remote_uri"] = @quote.remote_uri

    similar = @quote.nearest_neighbors(:embedding, distance: "cosine").first(5)
    json["similar_quotes"] = similar.map { |q| url_for(q) }

    render json: json
  end

  # GET /quotes/random
  def random
    http = HTTPX.with(headers: { 'accept': 'application/json', 'Content-Type': 'application/json' })

    @quote = Quote.find(Quote.pluck(:id).sample)

    response = http.get(@quote.remote_uri)
    json = JSON.parse(response.body)

    @remote_json = JSON.parse(response.body)

    json["id"] = @quote.id
    json["remote_uri"] = @quote.remote_uri

    similar = @quote.nearest_neighbors(:embedding, distance: "cosine").first(5)
    json["similar_quotes"] = similar.map { |q| url_for(q) }

    render json: json
  end
end
