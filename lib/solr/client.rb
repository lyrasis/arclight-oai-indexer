# frozen_string_literal: true

require 'logger'

module Solr
  class Client
    def self.client
      @client ||= Solr::Client.new(
        endpoint: ENV.fetch('SOLR_URL'),
        indexer: File::Utils.cache(
          filename: 'indexer.rb',
          content: HTTP.get(ENV.fetch('INDEXER_CONFIG_URL')).body
        ),
        logger: Logger.new(STDOUT)
      )
    end

    def self.delete(eadid:, logger: Logger.new(STDOUT))
      logger.info("Deleting: #{eadid}")
      client.delete(eadid: eadid)
      logger.info("Deleted: #{eadid}")
    end

    def self.index(file:, logger: Logger.new(STDOUT))
      logger.info("Indexing [#{ENV['REPOSITORY_ID']}]: #{file}")
      client.index(
        file: file
      )
      logger.info("Indexed [#{ENV['REPOSITORY_ID']}]: #{file}")
    end

    attr_reader :endpoint, :indexer, :logger, :solr
    def initialize(endpoint: nil, indexer: nil, logger: nil)
      @endpoint = endpoint
      @indexer  = indexer
      @logger   = logger
      @solr     = connect
    end

    def connect
      RSolr.connect(url: @endpoint)
    end

    def delete(eadid: nil)
      solr.get(
        'select',
        params: {
          q: solr.delete_by_query("ead_ssi:#{escape(eadid)}")
        }
      )
      solr.commit
    end

    def escape(string)
      RSolr.solr_escape(string)
    end

    def index(file: nil)
      `bundle exec traject -u #{endpoint} -i xml -c #{indexer} #{file}`
    end
  end
end
