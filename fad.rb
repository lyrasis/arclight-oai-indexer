# frozen_string_literal: true

require 'http'
require 'uri'
require 'yaml'
require 'nokogiri'

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
     .get(construct_list_endpoint(ENV['FAD_URL'], ENV['FAD_ENV']))
    # *. remove deleted records from index (new task required?)
    response.parse['items'].each do |item|
      if item['deleted'] == 'true'
        puts "I was deleted, do something"
        # Rake task here
      else
        item_url = item['url']
        # *. use API endpoint to get entire xml for resources
        resource = HTTP['x-api-key' => ENV['FAD_TOKEN']]
          .get(construct_resource_endpoint(ENV['FAD_URL'], ENV['FAD_ENV'], item_url))
        f = File.open("tempfile.xml", 'w', encoding: 'ascii-8bit')
        f.write(resource.body)
        f.close
        # Manipulate ead to add an eadid
        ead = Nokogiri::XML(open(f))
        eadid = ead.at_css "eadid"
        eadid.content = item_url
        File.open('tempfile.xml','w') { |file| file.write(ead) }
        # *. use arclight:index to ingest updated records
        begin
          ENV['FILE'] = 'tempfile.xml'
          Rake::Task['arclight:index'].invoke
          Rake::Task['arclight:index'].reenable
        rescue StandardError=>e
          puts "Error: #{e}"
        end
      end
    end
  end

  def construct_list_endpoint(fad_url, fad_env)
    url = File.join(fad_url, fad_env, 'demo', 'resources?since=0')
    parsed_url = URI.parse(url) rescue false
    if parsed_url.kind_of?(URI::HTTP) || parsed_url.kind_of?(URI::HTTPS)
      return url
    else
      raise "URL #{url} is invalid."
    end
  end

  def construct_resource_endpoint(fad_url, fad_env, item_url)
    url = File.join(fad_url, fad_env, 'demo', 'resources', "find?url=#{item_url}")
    parsed_url = URI.parse(url) rescue false
    if parsed_url.kind_of?(URI::HTTP) || parsed_url.kind_of?(URI::HTTPS)
      return url
    else
      raise "URL #{url} is invalid."
    end
  end

  desc 'Delete resources'
  task :index_fad_delete do
    # JSON only provides the url and deleted/not, so need to find reliable way to identify what exactly in arclight-index needs to be deleted.
    # solr.delete_by_query('*:*')
    # solr.commit
  end

end
