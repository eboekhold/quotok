# Quotok

Random quote API that uses semantic comparison to find similar quotes.

Visit the root page `/` and click through the similar quotes to explore the application.

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

OR add it to Rails' credentials with (you can replace `code` with whatever editor you prefer)

```
VISUAL="code --wait" bin/rails credentials:edit 
```

Then add:

```
openai_api_key: <your_api_key_here>
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
