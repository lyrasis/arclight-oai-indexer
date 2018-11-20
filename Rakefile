# frozen_string_literal: true

require_relative 'requirements'

namespace :arclight do
  namespace :solr do
    desc 'Delete a record by eadid'
    task :delete, [:eadid] do |_t, args|
      eadid = args[:eadid]
      raise 'No eadid marked for deletion' unless eadid

      solr = Solr::Client.new(endpoint: ENV.fetch('SOLR_URL'))
      solr.delete(eadid: eadid)
      puts "Delete query for #{eadid} completed."
    end
  end

  namespace :oai do
    def process(since: yesterday)
      oai = Fieldhand::Repository.new(ENV.fetch('OAI_ENDPOINT'))

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
        puts "No record updates since: #{since} for #{oai.uri}"
      end

      puts "Processed #{record_count} records in #{elapsed_time.round(3)} secs."
    end

    def yesterday
      Date.today.prev_day.to_s
    end

    desc 'Download oai retrieved records'
    task :download, [:since] do |_t, args|
      since = args[:since] ||= yesterday
      FileUtils.mkdir_p 'downloads'
      process(since: since) do |eadid, record|
        filename = eadid.gsub(%r{/}, '_').squeeze('_')
        ead      = Utils::OAI.ead(record: record)
        File.open(File.join('downloads', "#{filename}.xml"), 'w') do |f|
          f.write ead
        end
        puts "Downloaded: #{filename}"
      end
    end

    desc 'Index records using an OAI endpoint'
    task :index, [:since] do |_t, args|
      since = args[:since] ||= yesterday
      solr  = Solr::Client.new(
        endpoint: ENV.fetch('SOLR_URL'),
        indexer: ArcLight::Indexer.default_indexer
      )

      process(since: since) do |eadid, record|
        if !record.deleted?
          Utils::OAI.update_eadid(record: record, eadid: eadid)
          ead = Utils::OAI.ead(record: record)
          puts "Indexing eadid: #{eadid}"
          solr.index(
            file: Utils::File.write(content: ead)
          )
        else
          puts "Deleting eadid: #{eadid}"
          solr.delete(eadid: eadid)
        end
      end
    end
  end

  namespace :http do
    desc 'Index a record via url'
    task :index, [:url] do |_t, args|
      url = args[:url]
      raise 'No url specified for indexing' unless url

      solr = Solr::Client.new(
        endpoint: ENV.fetch('SOLR_URL'),
        indexer: ArcLight::Indexer.default_indexer
      )

      solr.index(
        file: Utils::File.write(content: HTTP.get(url).body)
      )

      puts "Indexed #{url}."
    end
  end
end
