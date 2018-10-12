# ArcLight OAI Indexer

Ingest OAI EAD documents into Solr using the ArcLight Indexer decoupled from the
BlackLight web app.

```bash
bundle install
docker-compose -f docker-compose-solr.yml build
docker-compose -f docker-compose-solr.yml up -d

# override .env (create: .env.local) to customize configuration
source .env # sets $URL
bundle exec rake arclight:http:index[$URL]
bundle exec rake arclight:solr:delete[a0011.xml]
bundle exec rake arclight:oai:index
```

Solr: http://localhost:8983/

## Docker

Run an indexer container:

```bash
docker-compose -f docker-compose-indexer.yml build
docker-compose -f docker-compose-indexer.yml up
```

Solr: http://localhost:8984/

See the `docker-compose-indexer.yml` for example configuration.

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
