require 'rails_helper'

RSpec.describe "/quotes", type: :request do

  before do
    stub_request(:any, /dummyjson/).
      to_return_json(body: {total: 123})
  end

  describe "GET /random" do
    before do
      uri_template = Addressable::Template.new "dummyjson.com/quotes/{id}"
      stub_request(:any, uri_template).
        to_return_json(body: {id: 42, quote: "Forgive people so that Allah may forgive you.", author: "Umar ibn Al-Khattāb (R.A)"})
    end
    
    it "renders a successful response" do
      get quotes_random_url, as: :json
      expect(response).to be_successful
    end
  end
end
