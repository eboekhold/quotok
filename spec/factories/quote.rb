FactoryBot.define do
  factory :quote do
    sequence(:remote_uri) { |n| "https://dummyjson.com/quotes/#{n}" }
    embedding { [*1..1536].map { |_| rand(-1.0...1.0) } }
  end
end
