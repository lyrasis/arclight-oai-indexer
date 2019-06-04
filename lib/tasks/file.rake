# frozen_string_literal: true

namespace :arclight do
  namespace :file do
    # bundle exec rake arclight:file:index[/path/to/file]
    desc 'Index a record using an EAD file'
    task :index, [:file] do |_t, args|
      logger = Logger.new(STDOUT)
      file   = args[:file]
      raise "File not found: #{file}" unless File.file?(file)

      solr = Solr::Client.new(
        endpoint: ENV.fetch('SOLR_URL'),
        indexer: ArcLight::Indexer.default_indexer,
        logger: logger
      )

      logger.info("Indexing: #{file}")
      solr.index(
        file: file
      )
      logger.info("Indexed: #{file}")
    end
  end
end
