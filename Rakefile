# frozen_string_literal: true

require 'arclight'
require 'benchmark'
require 'dotenv/load'
require 'http'
require 'nokogiri'
require 'rsolr'
require 'tmpdir'
require 'uri'
require 'yaml'

require_relative 'lib/fad/client'

##
# Environment variables for indexing (c.f. index.rb):
# FAD_ENV the deployment stage of the api (default: none).
# FAD_TOKEN access token (default: none).
# FAD_URL base url to FAD api endpoint (default: none).
# REPOSITORY_URL url to repositories.yml (default: none).
# REPOSITORY_ID repository shortname (default: demo).
#

namespace :arclight do
  namespace :fad do
    desc 'Print FAD config'
    task :config do
      puts JSON.pretty_generate FAD::Client.get_config
    end

    desc 'Delete a resource by eadid'
    task :delete, [:eadid] do |t, args|
      eadid = args[:eadid] ||= raise 'No eadid marked for deletion'
      fad = FAD::Client.new(config: FAD::Client.get_config)
      elapsed_time = fad.destroy(eadid: eadid)
      puts "Delete query for #{eadid} completed in #{elapsed_time.round(3)} secs."
    end

    desc 'Index resources via a FAD API endpoint'
    task :index_api do
      # TODO: -
      # *. sync config/repositories.yml using ENV.fetch('REPOSITORY_URL')
      # *. check ENV.fetch('REPOSITORY_ID') is valid (is in list of repos)
      # *. check whether use token is true
      site = { name: 'Demo Repository', restricted: true }
      restricted = site[:restricted] ? true : false

      fad = FAD::Client.new(config: FAD::Client.get_config(restricted))
      response = fad.records(since: 0)

      deletes, updates = response.parse['items'].partition do |i|
        i['deleted'] == 'true'
      end

      elapsed_time = fad.delete(records: deletes)
      puts "Deleted #{deletes.count} records in #{elapsed_time.round(3)} secs."

      elapsed_time = fad.update(records: updates)
      puts "Indexed #{updates.count} records in #{elapsed_time.round(3)} secs."
    end

    desc 'Index a resource via a url'
    task :index_url, [:url] do |t, args|
      url = args[:url] ||= raise 'No url specified for indexing'
      fad = FAD::Client.new(config: FAD::Client.get_config)
      elapsed_time = fad.index(
        file: fad.write_to_file(content: fad.download(url: url).body)
      )
      puts "Indexed #{url} in #{elapsed_time.round(3)} secs."
    end
  end
end
