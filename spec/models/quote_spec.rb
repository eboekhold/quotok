require 'rails_helper'

RSpec.describe Quote, type: :model do
  let(:quote) { FactoryBot.create(:quote) }

  describe '#remote_uri' do
    subject { quote.remote_uri }

    it { is_expected.to eq "https://dummyjson.com/quotes/1" }
  end
end
