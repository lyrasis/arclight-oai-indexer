# frozen_string_literal: true

require 'http'
require 'uri'
require 'yaml'

##
# Environment variables for indexing (c.f. index.rb):
#
# FAD_URL base url to FAD api endpoint (default: none).
#
# FAD_ENV the deployment stage of the api (default: none).
#
# FAD_TOKEN access token (default: none).
#
# REPOSITORY_URL url to repositories.yml (default: none).
#
# REPOSITORY_ID repository shortname (default: demo).
#
namespace :arclight do
  desc 'Index resources via a FAD API endpoint'
  task :index_fad do
    # TODO:
    # *. sync config/repositories.yml using ENV.fetch('REPOSITORY_URL')
    # *. check ENV.fetch('REPOSITORY_ID') is valid (is in list of repos)
    # *. get list of resources from fad
    response = HTTP['x-api-key' => ENV['FAD_TOKEN']]
     .get(construct_list_endpoint)
    # *. remove deleted records from index (new task required?)
    response.parse['items'].each do |item|
      if item['deleted'] == 'true'
        puts "I was deleted, do something"
      end
    end
    # *. use arclight:index_url to ingest updated records
    response.parse['items'].each do |item|
      begin
        ENV['URL'] = construct_resource_endpoint(item['url'])
        Rake::Task['arclight:index_url'].execute
      rescue StandardError=>e
        puts "Error: #{e}"
      end
    end
  end

  def construct_list_endpoint
    fad_url = ENV['FAD_URL']
    fad_env = ENV['FAD_ENV']
    return URI.decode(fad_url + '/' + fad_env + '/demo/resources?since=0')
  end

  def construct_resource_endpoint(item_url)
    fad_url = ENV['FAD_URL']
    fad_env = ENV['FAD_ENV']
    return URI.decode(fad_url + '/' + fad_env + '/demo/resources/find?url=' + item_url)
  end

end
