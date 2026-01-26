require 'rails_helper'

class MockEmbedding
  attr_reader :vectors

  def initialize(vectors)
    @vectors = vectors
  end
end


RSpec.describe QuoteSource, type: :model do
  let(:mocked_embeddings) { MockEmbedding.new(Array.new(number_of_quotes) { [ *1..1536 ].map { |_| rand(-1.0...1.0) } }) }
  let(:mocked_response_body) { { quotes: Array.new(number_of_quotes) { { id: Faker::Number.number(digits: 4), quote_key => Faker::Quote.yoda } } } }

  let(:dummy_website_url) { "https://dummy.website.com/quotes" }
  let(:quote_key) { 'string' }
  let(:quote_source) { QuoteSource.create(remote_path: "#{dummy_website_url}/", quote_field: quote_key, author_field: 'author') }

  let(:number_of_quotes) { 1 }

  before do
    stub_request(:any, dummy_website_url).to_return_json(body: mocked_response_body)
  end

  describe '#generate_quote_embeddings' do
    subject { quote_source.generate_quote_embeddings("", dummy_website_url) }

    context "when RubyLLM does not throw an error" do
      before { expect(RubyLLM).to receive(:embed).and_return(mocked_embeddings).once }

      it "creates a quote object" do
        expect { subject }.to change { Quote.count }.from(0).to(1)
      end

      context 'when the website returns 5 quotes' do
        let(:number_of_quotes) { 5 }

        it { expect { subject }.to change { Quote.count }.from(0).to(5) }
      end
    end

    context 'when RubyLLM throws an error' do
      before { expect(RubyLLM).to receive(:embed).and_raise(RubyLLM::Error) }

      it { expect { subject }.not_to change { Quote.count } }
      it { is_expected.to be false }
    end
  end
end
