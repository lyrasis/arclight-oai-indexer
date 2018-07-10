# ArcLight Indexer

Ingest EAD documents into Solr using the ArcLight Indexer decoupled from the
BlackLight web app.

```bash
bundle install
docker-compose -f docker-compose-solr.yml build # images for indexer and solr

# start local solr
docker-compose -f docker-compose-solr.yml run -p 8983:8983 -d solr

# set env for index from url
export REPOSITORY_FILE=./config/repositories.yml
export REPOSITORY_ID=demo
export SOLR_URL=http://127.0.0.1:8983/solr/arclight
export URL=https://raw.githubusercontent.com/sul-dlss/arclight/master/spec/fixtures/ead/sample/large-components-list.xml

# ingest the ead
bundle exec rake arclight:index_url
```

## Docker

Run an indexer container with default index url task:

```bash
docker-compose -f docker-compose-solr.yml run -p 8983:8983 -d solr # if not running
docker-compose -f docker-compose-indexer.yml build
docker-compose -f docker-compose-indexer.yml run --rm indexer
```

See the `docker-compose-indexer.yml` for example configuration.

## Todo

- Dockerfile
- Download repositories configuration option
- Rake task to index from FAD
