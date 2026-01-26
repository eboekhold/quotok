# Quotok

Quote API relying on external quote sources. Uses semantic comparison to find similar quotes.

Visit the root page `/` and navigate through the similar quotes to explore the application.

This API relies on both [DummyJSON](https://dummyjson.com) and [The Quotes Hub](https://thequoteshub.com) as sources of quotes.

As of writing there is a copy running on https://quotok-production.up.railway.app/ .

## Dependencies

- Ruby 3.4.7 (and Bundler)
- PostgreSQL with the [`pgvector`](https://github.com/pgvector/pgvector) extension
- An OpenAI API key and at least ~$0.01 in credits

## Installation

### OpenAI API Key

Set your OpenAI API key as environment variable:
```
export OPENAI_API_KEY=<your_key_here>
```

OR add it to Rails' credentials with: (replace `code` with the editor you prefer)

```
VISUAL="code --wait" bin/rails credentials:edit 
```

Then add:

```
openai_api_key: <your_key_here>
```

### Server setup

Download and install all the gems by running:
```
bundle install
```

Then set up the database:
```
bin/rails db:create
bin/rails db:migrate
```

Check if all the specs run:
```
RAILS_ENV=test bin/rails db:setup

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

They both support one optional parameter:
- `?similar=<number>` -- to specify how many similar neighbor quotes you want.

The root of the server `/` also returns the same result as `/quotes/random` does.

Example requests:
- http://localhost:3000/quotes/12?similar=50  -- for local server
- https://quotok-production.up.railway.app/quotes/random?similar=42 -- for live server

## OpenAI Token use

This application uses OpenAI's `text-embedding-3-small` model.
Seeding the database currently uses <100k tokens.
