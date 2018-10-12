# frozen_string_literal: true

require 'arclight'
require 'benchmark'
require 'dotenv/load'
require 'http'
require 'nokogiri'
require 'oai'
require 'rsolr'
require 'tmpdir'
require 'uri'
require 'yaml'

require_relative 'lib/arclight/indexer'
require_relative 'lib/solr/client'
require_relative 'lib/utils/file'

namespace :arclight do

  namespace :solr do
    desc 'Delete a record by eadid'
    task :delete, [:eadid] do |t, args|
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
    task :index, [:since] do |t, args|
      since = args[:since] ||= yesterday

      oai  = OAI::Client.new(ENV.fetch('OAI_ENDPOINT'))
      solr = Solr::Client.new(
        endpoint: ENV.fetch('SOLR_URL'),
        indexer:  ArcLight::Indexer.default_indexer
      )

      record_count = 0
      elapsed_time = 0

      oai.list_records(:metadata_prefix => 'oai_ead', from: since).full.each do |record|
        ead = REXML::XPath.first(record.metadata, '//ead')
        elapsed_time += solr.index(
          file: Utils::File.write(content: ead)
        )
        record_count += 1
      end

      puts "Indexed #{record_count} records in #{elapsed_time.round(3)} secs."
    end
  end

  namespace :http do
    desc 'Index a record via url'
    task :index, [:url] do |t, args|
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
