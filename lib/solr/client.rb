# frozen_string_literal: true

module Solr
  class Client
    attr_reader :endpoint, :indexer, :solr

    def initialize(endpoint: nil, indexer: nil)
      @endpoint = endpoint
      @indexer  = indexer
      @solr     = connect
    end

    def connect
      RSolr.connect(url: @endpoint)
    end

    def delete(eadid: nil)
      Benchmark.realtime do
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
      Benchmark.realtime do
        indexer.update(file)
      end
    end
  end
end
