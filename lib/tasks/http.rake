# frozen_string_literal: true

namespace :arclight do
  namespace :http do
    desc 'Index a record from a url'
    task :index, [:url] do |_t, args|
      logger = Logger.new(STDOUT)
      url    = args[:url]
      raise 'No url specified for indexing' unless url

      solr = Solr::Client.new(
        endpoint: ENV.fetch('SOLR_URL'),
        indexer: ArcLight::Indexer.default_indexer,
        logger: logger
      )

      logger.info("Indexing: #{url}")
      solr.index(
        file: Utils::File.cache(content: HTTP.get(url).body)
      )
      logger.info("Indexed: #{url}")
    end
  end
end
