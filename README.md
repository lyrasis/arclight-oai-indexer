# ArcLight OAI Indexer

Ingest OAI EAD documents into Solr using the ArcLight Indexer decoupled from the
BlackLight web app.

```bash
bundle install
docker-compose build
docker-compose up -d solr # run solr only

# override .env (create: .env.local) to customize configuration
source .env # sets $URL
bundle exec rake arclight:http:index[$URL]
bundle exec rake arclight:solr:delete[a0011.xml]
bundle exec rake arclight:oai:index
```

Solr: http://localhost:8983/

Run an indexer container:

```bash
docker-compose stop solr && docker-compose rm -f solr
docker-compose up # -d for background
```

The indexer container will run until complete:

`arclight-indexer_indexer_1 exited with code 0`

See the `docker-compose.yml` for example configuration.

## ArcLight

To test with a local ArcLight download it then:

```bash
bundle install
bundle exec rake arclight:generate
cd .internal_test_app
# update config/repositories.yml
SOLR_URL=http://localhost:8984/solr/arclight ./bin/rails s
```

---
