require "ruby_llm"

RubyLLM.configure do |config|
  if Rails.env.development? || Rails.env.production?
    config.openai_api_key = ENV.fetch("OPENAI_API_KEY", nil) || Rails.application.credentials.openai_api_key
  end
end
