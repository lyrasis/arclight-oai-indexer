# frozen_string_literal: true

require_relative 'requirements'

namespace :arclight do
  namespace :solr do
    desc 'Delete a record by eadid'
    task :delete, [:eadid] do |_t, args|
      logger = Logger.new(STDOUT)
      eadid  = args[:eadid]
      raise 'No eadid marked for deletion' unless eadid

      solr = Solr::Client.new(endpoint: ENV.fetch('SOLR_URL'))
      solr.delete(eadid: eadid)
      logger.info("Delete query for #{eadid} completed.")
    end
  end

  namespace :oai do
    def process(since: yesterday, logger: nil)
      oai = Fieldhand::Repository.new(
        ENV.fetch('OAI_ENDPOINT'),
        logger: logger,
        timeout: 300
      )

      record_count = 0
      elapsed_time = 0

      begin
        oai.records(metadata_prefix: 'oai_ead', from: since).each do |record|
          record_count += 1
          eadid = record.identifier
          elapsed_time += Benchmark.realtime do
            yield eadid, record
          end
        end
      rescue Fieldhand::NoRecordsMatchError
        logger.info("No record updates since: #{since} for #{oai.uri}")
      end

      logger.info("Processed #{record_count} records in #{elapsed_time.round(3)} secs.")
    end

    def yesterday
      Date.today.prev_day.to_s
    end

    desc 'Download oai retrieved records'
    task :download, [:since] do |_t, args|
      logger = Logger.new(STDOUT)
      since  = args[:since] ||= yesterday
      FileUtils.mkdir_p 'downloads'
      process(since: since, logger: logger) do |eadid, record|
        filename = eadid.gsub(%r{/}, '_').squeeze('_')
        ead      = Utils::OAI.ead(record: record)
        File.open(File.join('downloads', "#{filename}.xml"), 'w') do |f|
          f.write ead
        end
        logger.info("Downloaded: #{filename}")
      end
    end

    desc 'Index records using an OAI endpoint'
    task :index, [:since] do |_t, args|
      logger = Logger.new(STDOUT)
      since  = args[:since] ||= yesterday
      solr   = Solr::Client.new(
        endpoint: ENV.fetch('SOLR_URL'),
        indexer: ArcLight::Indexer.default_indexer
      )
      index_files = []

      process(since: since, logger: logger) do |eadid, record|
        if !record.deleted?
          Utils::OAI.update_eadid(record: record, eadid: eadid)
          filename = eadid.gsub(%r{/}, '_').squeeze('_')
          ead      = Utils::OAI.ead(record: record)
          index_files << Utils::File.cache(filename: filename, content: ead)
          logger.info("Downloaded: #{index_files[-1]}")
        else
          logger.info("Deleting: #{eadid}")
          solr.delete(eadid: eadid)
        end
      end

      index_files.each do |file|
        logger.info("Indexing: #{file}")
        solr.index(
          file: file
        )
        FileUtils.rm(file, force: true)
      end
    end
  end

  namespace :http do
    desc 'Index a record via url'
    task :index, [:url] do |_t, args|
      logger = Logger.new(STDOUT)
      url    = args[:url]
      raise 'No url specified for indexing' unless url

      solr = Solr::Client.new(
        endpoint: ENV.fetch('SOLR_URL'),
        indexer: ArcLight::Indexer.default_indexer
      )

      solr.index(
        file: Utils::File.cache(content: HTTP.get(url).body)
      )

      logger.info("Indexed #{url}.")
    end
  end
end
