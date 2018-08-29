# frozen_string_literal: true

require 'http'
require 'uri'
require 'yaml'
require 'nokogiri'
require 'rsolr'
require 'benchmark'

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
    config = {
      token: ENV['FAD_TOKEN'],
      url: ENV['FAD_URL'],
      env: ENV['FAD_ENV'],
      site: ENV['REPOSITORY_ID'],
      solr_url: ENV['SOLR_URL']
    }

    # TODO: -
    # *. sync config/repositories.yml using ENV.fetch('REPOSITORY_URL')
    # *. check ENV.fetch('REPOSITORY_ID') is valid (is in list of repos)

    response = get_list(config, 0)
    deletes, updates = response.parse['items'].partition do |i|
      i['deleted'] == 'true'
    end

    # *. remove deleted records from index (new task required?)
    handle_deletes(config, deletes)
    handle_updates(config, updates)
  end

  def construct_list_endpoint(config, since = 0)
    url = File.join(
      config[:url],
      config[:env],
      config[:site],
      "resources?since=#{since}"
    )
    parse_url(url)
  end

  def construct_resource_endpoint(config, item_url)
    url = File.join(
      config[:url],
      config[:env],
      config[:site],
      'resources',
      "find?url=#{item_url}"
    )
    parse_url(url)
  end

  def get_list(config, since = 0)
    HTTP['x-api-key' => config[:token]]
      .get(construct_list_endpoint(config, since))
  end

  def get_resource(config, item_url)
    HTTP['x-api-key' => config[:token]]
      .get(construct_resource_endpoint(config, item_url))
  end

  def handle_deletes(config, deletes)
    deletes.each do |item|
      item_url = RSolr.solr_escape(item['url'])
      solr = RSolr.connect :url => config[:solr_url]
      results = solr.get 'select', :params => {:q=>"ead_ssi:#{item_url}"}
      unless results['response']['docs'] == []
        delete_uri = results['response']['docs'][0]['ead_ssi']
        delete_coll(delete_uri)
      end
    end
  end

  def delete_coll(coll)
    begin
      ENV['coll'] = coll
      Rake::Task['arclight:index_fad_delete'].invoke
      Rake::Task['arclight:index_fad_delete'].reenable
    rescue StandardError => e
      puts "Error: #{e}"
    end
  end

  def handle_updates(config, updates)
    updates.each do |item|
      item_url = item['url']
      resource = get_resource(config, item_url)
      ead = Nokogiri::XML(resource.body)
      update_eadid(ead, item_url)
      File.open('tempfile.xml', 'w') { |file| file.write(ead) }
      index_file('tempfile.xml')
    end
  end

  def index_file(file)
    begin
      ENV['FILE'] = file
      Rake::Task['arclight:index'].invoke
      Rake::Task['arclight:index'].reenable
    rescue StandardError => e
      puts "Error: #{e}"
    end
  end

  def parse_url(url)
    parsed_url = begin
                   URI.parse(url)
                 rescue StandardError
                   false
                 end
    if parsed_url.is_a?(URI::HTTP) || parsed_url.is_a?(URI::HTTPS)
      return url
    else
      raise "URL #{url} is invalid."
    end
  end

  def update_eadid(xml, identifier)
    eadid = xml.at_css 'eadid'
    eadid.content = identifier
  end

  desc 'Delete resources'
  task :index_fad_delete do
    config = {
      solr_url: ENV['SOLR_URL']
    }
    raise 'No collections marked for deletion' unless ENV['coll']
    print "Deleting #{ENV['coll']} ...\n"
    solr = RSolr.connect :url => config[:solr_url]
    elapsed_time = Benchmark.realtime { solr.get('select', :params => {:q=>"ead_ssi:#{RSolr.solr_escape(ENV['coll'])}"}) !=[] ? solr.delete_by_query("ead_ssi:#{RSolr.solr_escape(ENV['coll'])}") : next }
    solr.commit
    print "Deleted #{ENV['coll']} (in #{elapsed_time.round(3)} secs).\n"
  end
end
