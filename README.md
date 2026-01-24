# Quotok

Random quote API that uses semantic comparison to find similar quotes.

## Dependencies

- Ruby 3.4.7 (and Bundler)
- PostgreSQL
- An OpenAI API key and at least ~$0.01 in credits

## Installation

Set your OpenAI API key as environment variable:
```
export OPENAI_API_KEY=<your_key_here>
```

Download and install all the gems by running:
```
bundle install
```

Then set up the database:
```
bin/rails db:setup
```

Check if all the specs run:
```
rspec
```

Seed the database: (this uses OpenAI tokens)
```
bin/rails db:seed
```

Finally, run the server:
```
bin/rails s
```

## API

There are two endpoints:
- `/quotes/random` -- returns a random quote
- `/quotes/{:id}` -- returns a specific quote

The root of the server `/` also returns the same result as `/quotes/random` does.

## OpenAI Token use

This application uses OpenAI's `text-embedding-3-small` model.
Seeding the database currently uses ~30k tokens.
