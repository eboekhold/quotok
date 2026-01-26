class QuotesController < ApplicationController
  DEFAULT_AMOUNT_OF_NEIGHBORS = 5
  PG_MAX_BIGINT = 9223372036854775807

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
      json = {}

      json["id"] = quote.id
      json["remote_uri"] = quote.remote_uri
      json["similar_quotes"] = nearest_neighbors(quote).map { |neighbor| url_for(neighbor) }

      unless response.error
        quote_source = quote.quote_source
        remote_json = JSON.parse(response.body)

        json["quote"] = remote_json[quote_source.quote_field]
        json["author"] = remote_json[quote_source.author_field]
      else
        json["remote_error"] = error_text(response)
      end

      json
    end

    def nearest_neighbors(quote)
      amount_of_neighbors = quote_params[:similar].present? ? quote_params[:similar].to_i : DEFAULT_AMOUNT_OF_NEIGHBORS
      amount_of_neighbors = [ amount_of_neighbors, PG_MAX_BIGINT ].min

      neighbors = quote.nearest_neighbors(:embedding, distance: "cosine").first(amount_of_neighbors)
    end

    def error_text(response)
      if response.try(:body).present?
        JSON.parse(response.body)
      else
        response.error.message
      end
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

    def quote_params
      params.permit(:id, :similar)
    end
end
