# frozen_string_literal: true

require_relative 'requirements'

namespace :arclight do
  namespace :solr do
    desc 'Delete a record by eadid'
    task :delete, [:eadid] do |_t, args|
      eadid = args[:eadid]
      raise 'No eadid marked for deletion' unless eadid

      solr = Solr::Client.new(endpoint: ENV.fetch('SOLR_URL'))
      elapsed_time = solr.delete(eadid: eadid)
      puts "Delete query for #{eadid} completed in #{elapsed_time.round(3)} secs."
    end
  end

  namespace :oai do
    def yesterday
      Date.today.prev_day.to_s
    end

    desc 'Index records using an OAI endpoint'
    task :index, [:since] do |_t, args|
      since = args[:since] ||= yesterday

      oai  = Fieldhand::Repository.new(ENV.fetch('OAI_ENDPOINT'))
      solr = Solr::Client.new(
        endpoint: ENV.fetch('SOLR_URL'),
        indexer:  ArcLight::Indexer.default_indexer
      )

      record_count = 0
      elapsed_time = 0

      oai.records(metadata_prefix: 'oai_ead', from: since).each do |record|
        eadid = record.identifier
        if !record.deleted?
          Utils::OAI.update_eadid(record: record, eadid: eadid)
          ead = Utils::OAI.ead(record: record)
          puts "Indexing eadid: #{eadid}"
          elapsed_time += solr.index(
            file: Utils::File.write(content: ead)
          )
        else
          puts "Deleting eadid: #{eadid}"
          elapsed_time += solr.delete(eadid: eadid)
        end
        record_count += 1
      end

      puts "Indexed / deleted #{record_count} records in #{elapsed_time.round(3)} secs."
    end
  end

  namespace :http do
    desc 'Index a record via url'
    task :index, [:url] do |_t, args|
      url = args[:url]
      raise 'No url specified for indexing' unless url

      solr = Solr::Client.new(
        endpoint: ENV.fetch('SOLR_URL'),
        indexer:  ArcLight::Indexer.default_indexer
      )

      elapsed_time = solr.index(
        file: Utils::File.write(content: HTTP.get(url).body)
      )

      puts "Indexed #{url} in #{elapsed_time.round(3)} secs."
    end
  end
end
