class QuotesController < ApplicationController
  # GET /quotes/{:id}
  def show
    quote = Quote.find(params.expect(:id))

    response = remote_quote(quote)

    render json: prepare_json(response, quote), status: status_from(response)
  end

  # GET /quotes/random
  def random
    quote = Quote.find(Quote.pluck(:id).sample)

    response = remote_quote(quote)

    render json: prepare_json(response, quote), status: status_from(response)
  end

  private
    def remote_quote(quote)
      http = HTTPX.with(headers: { 'accept': "application/json", 'Content-Type': "application/json" })

      http.get(quote.remote_uri)
    end

    def prepare_json(response, quote)
      quote_source = quote.quote_source

      json = {}

      json["id"] = quote.id
      json["remote_uri"] = quote.remote_uri

      similar = quote.nearest_neighbors(:embedding, distance: "cosine").first(5)
      json["similar_quotes"] = similar.map { |similar_quote| url_for(similar_quote) }

      if response.error
        if response.try(:body).present?
          response_body = JSON.parse(response.body)
        else
          response_body = response.error.message
        end
        json["remote_error"] = response_body
      else
        remote_json = JSON.parse(response.body)
        json["quote"] = remote_json[quote_source.quote_field]
        json["author"] = remote_json[quote_source.author_field]
      end

      json
    end

    def status_from(response)
      remote_request_status = response.try(:status)

      if remote_request_status == 200 || remote_request_status == 404 # OK or NOT FOUND
        remote_request_status
      elsif response.error.is_a? HTTPX::TimeoutError
        504 # Gateway Timeout
      else
        502 # Bad Gateway
      end
    end
end
