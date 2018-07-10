# ArcLight Indexer

Ingest EAD documents into Solr using the ArcLight Indexer decoupled from the
BlackLight web app.

```bash
bundle install

# start local solr
cd solr && docker-compose up -d && cd -

# set env for index from url
export REPOSITORY_FILE=./config/repositories.yml
export REPOSITORY_ID=demo
export SOLR_URL=http://127.0.0.1:8983/solr/arclight
export URL=https://raw.githubusercontent.com/sul-dlss/arclight/master/spec/fixtures/ead/sample/large-components-list.xml

# ingest the ead
bundle exec rake arclight:index_url
```

## Todo

- Dockerfile
- Download repositories configuration option
- Rake task to index from FAD
