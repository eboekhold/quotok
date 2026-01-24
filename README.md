# Quotok

Random quote API

## Dependencies

- Ruby (and Bundler) 3.4.7
- PostgreSQL

## Installation

First download and install all the gems by running:

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

Finally, run the server:
```
bin/rails s
```

## API

There is one endpoint:
- `/random`

Optionally, the root of the server `/` also returns the same result as `/random` does.
