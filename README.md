# ArcLight OAI Indexer

[![Build Status](https://travis-ci.org/lyrasis/arclight-oai-indexer.svg?branch=master)](https://travis-ci.org/lyrasis/arclight-oai-indexer) [![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](http://opensource.org/licenses/MIT)

Ingest OAI EAD documents into Solr using the ArcLight Indexer decoupled from the
BlackLight web app.

## Quickstart

To get up and running quickly there is a prebuilt image on Docker Hub:

```bash
docker run -it --rm \
  -e OAI_ENDPOINT=https://archives.example.org/oai \
  -e REPOSITORY_URL=https://archives.example.org/repositories.yml \
  -e SOLR_URL=http://solr.example.org:8983/solr/arclight \
  lyrasis/arclight-oai-indexer:latest
```

For this to work the container must be able to access the oai and solr urls, and
the Solr instance should be using [ArcLight's Solr configuration](https://github.com/sul-dlss/arclight/tree/master/solr/conf).

The `REPOSITORY_URL` must point to a [publicly downloadable configuration](https://s3-us-west-2.amazonaws.com/as-public-shared-files/dts/dts.repo.yml) file.

By default the indexer requests records updated since the previous day but you
can specify the "from" date explicitly:

```bash
docker run -it --rm \
  # ... as before
  lyrasis/arclight-oai-indexer:latest bundle exec rake arclight:index:oai[1970-01-01]
```

This is useful for populating an empty index or for full reindexing.

## Setup

```bash
bundle install
docker-compose build
```

## Running the indexer locally

```bash
# run solr locally with docker (optional)
docker-compose up -d solr

# to override `.env` create `.env.local` for custom configuration
SINCE=1970-01-01
bundle exec rake arclight:index:oai[$SINCE]
```

Docker Solr: http://localhost:8983/

## Running the indexer in a container

Run an indexer container:

```bash
docker-compose stop solr && docker-compose rm -f solr
docker-compose up # -d for background
```

The indexer container will run until indexing is complete:

`arclight-indexer_indexer_1 exited with code 0`

See the `docker-compose.yml` for example configuration.

## Using a remote Solr instance

```bash
# these values should be set in `.env.local`
OAI_ENDPOINT=https://archives.example.org/oai
SOLR_URL=http://solr.example.org:8983/solr/arclight
bundle exec rake arclight:index:oai
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

## Deployment options

- run container on a server using cron
- run using CloudWatch Events and ECS Fargate

## Downloading EAD

Export OAI EAD to `./downloads/`:

```bash
SINCE=1970-01-01
bundle exec rake arclight:download:oai[$SINCE]
```

You can then index using the directory:

```bash
bundle exec rake arclight:index:dir[downloads]
```

## License

The project is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

---
