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
# FAD_URL base url to FAD api endpoint (default: none).
# FAD_ENV the deployment stage of the api (default: none).
# FAD_TOKEN access token (default: none).
# REPOSITORY_URL url to repositories.yml (default: none).
# REPOSITORY_ID repository shortname (default: demo).
#

namespace :arclight do
  desc 'Delete a resource by eadid'
  task :delete_by_eadid, [:eadid] do |t, args|
    eadid = args[:eadid]
    raise 'No eadid marked for deletion' unless eadid
    fad = FAD::Client.new(FAD::Client.get_config)
    elapsed_time = fad.destroy(eadid: eadid)
    puts "Delete query for #{eadid} completed in #{elapsed_time.round(3)} secs."
  end

  namespace :fad do
    desc 'Print FAD config'
    task :config do
      puts FAD::Client.get_config
    end

    desc 'Index resources via a FAD API endpoint'
    task :index do
      # TODO: -
      # *. sync config/repositories.yml using ENV.fetch('REPOSITORY_URL')
      # *. check ENV.fetch('REPOSITORY_ID') is valid (is in list of repos)

      fad = FAD::Client.new(FAD::Client.get_config)
      response = fad.records(since: 0)

      deletes, updates = response.parse['items'].partition do |i|
        i['deleted'] == 'true'
      end

      elapsed_time = fad.delete(records: deletes)
      puts "Deleted #{deletes.count} records in #{elapsed_time.round(3)} secs."

      elapsed_time = fad.update(records: updates)
      puts "Indexed #{updates.count} records in #{elapsed_time.round(3)} secs."
    end
  end
end
