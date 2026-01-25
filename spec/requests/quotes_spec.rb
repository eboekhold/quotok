require 'rails_helper'

RSpec.describe "/quotes", type: :request do
  let(:dummyjson_stub) do
    uri_template = Addressable::Template.new "https://dummyjson.com/quotes/{id}"
    stub_request(:any, uri_template).
      to_return_json(body: { id: Faker::Number.number(digits: 4), quote: Faker::Quote.yoda, author: Faker::Name.name })
  end

  let(:thequoteshub_stub) do
    uri_template = Addressable::Template.new "https://thequoteshub.com/api/quotes/{id}"
    stub_request(:any, uri_template).
      to_return_json(body: { id: Faker::Number.number(digits: 4), text: Faker::Quote.fortune_cookie, author: Faker::Name.name })
  end

  describe "GET /show/{:id}" do
    subject { get quote_url(quote), as: :json }

    context "when the quote does not exist" do
      it "renders a 404" do
        get quote_url(1), as: :json

        expect(response.status).to eq(404)
      end
    end

    context "when the quote comes from dummyjson" do
      let(:quote) { FactoryBot.create(:quote) }

      before do
        dummyjson_stub
        subject
      end

      it "renders a successful response" do
        expect(response).to be_successful
      end

      it "calls dummyjson once" do
        expect(dummyjson_stub).to have_been_requested.once
      end
    end

    context "when the quote comes from thequoteshub" do
      let(:quote) { FactoryBot.create(:quote, :thequoteshub) }

      before do
        thequoteshub_stub
        subject
      end

      it "renders a succesful response" do
        expect(response).to be_successful
      end

      it "calls thequoteshub once" do
        expect(thequoteshub_stub).to have_been_requested.once
      end

      it "all required fields are present" do
        json = JSON.parse(response.body)

        expect(json['quote']).not_to be_empty
        expect(json['author']).not_to be_empty
        expect(json['remote_uri']).to include "thequoteshub"
      end
    end

    context "when multiple quotes exist" do
      let(:quote) { FactoryBot.create(:quote) }

      before do
        dummyjson_stub
        10.times { FactoryBot.create(:quote) }

        subject
      end

      it "has similar quotes" do
        json = JSON.parse(response.body)

        expect(json["similar_quotes"]).not_to be_empty
      end

      it "calls dummyjson once" do
        expect(dummyjson_stub).to have_been_requested.once
      end
    end
  end

  # Very similar to #show so this is just a smoke test
  describe "GET /random" do
    before do
      dummyjson_stub
      FactoryBot.create(:quote)

      subject
    end

    subject { get quotes_random_url, as: :json }

    it "renders a successful response" do
      expect(response).to be_successful
    end
  end
end
