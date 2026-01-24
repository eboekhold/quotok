require 'rails_helper'

RSpec.describe "/quotes", type: :request do

  before do
    stub_request(:any, /dummyjson/).
      to_return_json(body: {total: 123})

    uri_template = Addressable::Template.new "dummyjson.com/quotes/{id}"
    stub_request(:any, uri_template).
      to_return_json(body: {id: Faker::Number.number(digits: 4), quote: Faker::Quote.yoda, author: Faker::Name.name})
  end

  describe "GET /show/{:id}" do
    context "when the quote does not exist" do
      it "renders a 404" do
        get quote_url(1), as: :json
        expect(response.status).to eq(404)
      end
    end

    context "when the quote exists" do
      let(:quote) { FactoryBot.create(:quote) }

      it "renders a successful response" do
        get quote_url(quote), as: :json
        expect(response).to be_successful
      end

      context "when multiple quotes exist" do
        before { 10.times { FactoryBot.create(:quote) } }

        it "has similar quotes" do
          get quote_url(quote), as: :json

          json = JSON.parse(response.body)

          expect(json["similar_quotes"]).not_to be_empty
        end
      end
    end
  end

  # Very similar to #show so we just do a smoke test
  describe "GET /random" do
    before { FactoryBot.create(:quote) }
    
    it "renders a successful response" do
      get quotes_random_url, as: :json
      expect(response).to be_successful
    end
  end
end
