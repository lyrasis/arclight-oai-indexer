# ArcLight Indexer

Ingest EAD documents into Solr using the ArcLight Indexer decoupled from the
BlackLight web app.

```bash
bundle install
docker-compose -f docker-compose-solr.yml build
docker-compose -f docker-compose-solr.yml run -p 8983:8983 -d solr

# override .env (create: .env.local) to customize configuration
source .env # sets $URL
bundle exec rake arclight:fad:index_url[$URL]
bundle exec rake arclight:fad:delete[lc0100]
bundle exec rake arclight:fad:index_api
```

## Docker

Run an indexer container with default index url task:

```bash
docker-compose -f docker-compose-solr.yml run -p 8983:8983 -d solr # if not running
docker-compose -f docker-compose-indexer.yml build
docker-compose -f docker-compose-indexer.yml run --rm indexer
```

See the `docker-compose-indexer.yml` for example configuration.

---
