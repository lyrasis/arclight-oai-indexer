# frozen_string_literal: true

require 'logger'

module Solr
  class Client
    def self.client
      @client ||= Solr::Client.new(
        endpoint: ENV.fetch('SOLR_URL'),
        indexer: ArcLight::Indexer.default_indexer,
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
      with_retry do
        solr.get(
          'select',
          params: {
            q: solr.delete_by_query("ead_ssi:#{escape(eadid)}")
          }
        )
        solr.commit
      end
    end

    def escape(string)
      RSolr.solr_escape(string)
    end

    def index(file: nil)
      with_retry do
        indexer.update(file)
      end
    end

    def with_retry
      attempts = 0
      loop do
        begin
          yield
          break
        rescue RSolr::Error::ConnectionRefused => ex
          raise ex if attempts == 5

          logger.warn("Retrying connection to Solr: #{ex.message}")
          sleep((attempts += 1) * 30)
        end
      end
    end
  end
end
