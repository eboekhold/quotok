FactoryBot.define do
  factory :quote do
    sequence(:remote_id) { |n| "#{n}" }
    quote_source { QuoteSource.first }

    embedding { [ *1..1536 ].map { |_| rand(-1.0...1.0) } }

    trait :thequoteshub do
      sequence(:remote_id) { |n| "#{n}" }
      quote_source { QuoteSource.second }
    end
  end
end
