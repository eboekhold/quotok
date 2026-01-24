require 'rails_helper'

RSpec.describe "/quotes", type: :request do

  before do
    stub_request(:any, /dummyjson/).
      to_return_json(body: {total: 123})

    uri_template = Addressable::Template.new "dummyjson.com/quotes/{id}"
    stub_request(:any, uri_template).
      to_return_json(body: {id: Faker::Number.number(digits: 4), quote: Faker::Quote.yoda, author: Faker::Name.name})
  end

  describe "GET /random" do
    before { FactoryBot.create(:quote) }
    
    it "renders a successful response" do
      get quotes_random_url, as: :json
      expect(response).to be_successful
    end
  end
end
