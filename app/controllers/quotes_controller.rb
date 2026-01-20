class QuotesController < ApplicationController
  # GET /quotes/random
  def random
    http = HTTPX.with(headers: { 'accept': 'application/json', 'Content-Type': 'application/json' })

    response = http.get("https://dummyjson.com/quotes?limit=1")
    json = JSON.parse(response.body)

    total = json["total"]
    random_id = rand(1..total)

    response = http.get("https://dummyjson.com/quotes/#{random_id}")

    render json: JSON.parse(response.body)
  end
end
