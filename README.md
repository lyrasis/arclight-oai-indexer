# ArcLight OAI Indexer

Ingest OAI EAD documents into Solr using the ArcLight Indexer decoupled from the
BlackLight web app.

## Quickstart

To get up and running quickly there is a prebuilt image on Docker Hub:

```bash
docker run -it --rm \
  -e OAI_ENDPOINT=https://archives.example.org/oai \
  -e SOLR_URL=http://solr.example.org:8983/solr/arclight \
  lyrasis/arclight-oai-indexer:latest
```

For this to work the container must be able to access the oai and solr urls, and
the Solr instance should be using [ArcLight's Solr configuration](https://github.com/sul-dlss/arclight/tree/master/solr/conf).

By default the indexer requests records updated since the previous day but you
can specify the date explicitly:

```bash
docker run -it --rm \
  # ... as before
  lyrasis/arclight-oai-indexer:latest bundle exec rake arclight:oai:index[1970-01-01]
```

This is useful for populating an empty index or for full reindexing.

## Setup

```bash
bundle install
docker-compose build
docker-compose up -d solr # run solr locally with docker (optional)

# to override `.env` create `.env.local` for custom configuration
source .env # sets $URL
bundle exec rake arclight:http:index[$URL]
bundle exec rake arclight:solr:delete[a0011.xml]
SINCE=1970-01-01
bundle exec rake arclight:oai:index[$SINCE]
```

Docker Solr: http://localhost:8983/

Run an indexer container:

```bash
docker-compose stop solr && docker-compose rm -f solr
docker-compose up # -d for background
```

The indexer container will run until indexing is complete:

`arclight-indexer_indexer_1 exited with code 0`

See the `docker-compose.yml` for example configuration.

## Remote Solr example

```bash
# these values can be set in `.env.local`
OAI_ENDPOINT=https://archives.example.org/oai
SOLR_URL=http://solr.example.org:8983/solr/arclight
bundle exec rake arclight:oai:index
```

Or, with Docker:

```bash
docker run -it --rm \
  -e OAI_ENDPOINT=https://archives.example.org/oai \
  -e SOLR_URL=http://solr.example.org:8983/solr/arclight \
  arclight/indexer
```

The container must be able to access the oai and solr urls.

## ArcLight

To test with a local ArcLight download it then start Solr and:

```bash
bundle install
bundle exec rake arclight:generate
cd .internal_test_app
# update config/repositories.yml
SOLR_URL=http://localhost:8983/solr/arclight ./bin/rails s
```

## Downloading EAD

Export OAI EAD to `./downloads/`:

```bash
SINCE=1970-01-01
bundle exec rake arclight:oai:download[$SINCE]
```

---
