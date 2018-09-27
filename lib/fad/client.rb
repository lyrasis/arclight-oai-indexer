module FAD

  class Client

    attr_reader :config, :indexer, :solr

    def initialize(config: {}, options: {})
      @config = {
        token: nil,
        url: nil,
        env: nil,
        site: nil,
        solr_url: nil,
      }.merge(config)

      @options = {
        document: Arclight::CustomDocument,
        component: Arclight::CustomComponent
      }.merge(options)
      @indexer = Arclight::Indexer.new(options)

      @solr = RSolr.connect(url: config[:solr_url]) # TODO: move
    end

    def construct_list_endpoint(since: 0)
      url = File.join(
        config[:url],
        config[:env],
        config[:site],
        "resources?since=#{since}"
      )
      parse_url(url)
    end

    def construct_resource_endpoint(record_url: nil)
      url = File.join(
        config[:url],
        config[:env],
        config[:site],
        'resources',
        "find?url=#{record_url}"
      )
      parse_url(url)
    end

    def delete(records: [])
      records.each do |record|
        destroy(eadid: record['url'])
      end
    end

    def destroy(eadid: nil)
      elapsed_time = Benchmark.realtime do
        solr.get(
          'select',
          params: {
            q: solr.delete_by_query("ead_ssi:#{solr_escape(eadid)}")
          }
        )
        solr.commit
      end
      print "Deleted #{eadid} (in #{elapsed_time.round(3)} secs).\n"
    end

    def index(file: nil)
      elapsed_time = Benchmark.realtime { indexer.update(file) }
      print "Indexed #{ENV['FILE']} (in #{elapsed_time.round(3)} secs).\n"
    end

    def records(since: 0)
      HTTP['x-api-key' => config[:token]]
        .get(construct_list_endpoint(since: since))
    end

    def record(url: nil)
      HTTP['x-api-key' => config[:token]]
        .get(construct_resource_endpoint(url: record_url))
    end

    def update(records: [])
      records.each do |record|
        record_url = record['url']
        resource = record(url: record_url)
        ead = Nokogiri::XML(resource.body)
        update_eadid(ead, record_url)
        file = File.join(Dir.tmpdir, 'fad.xml')
        File.open(f, 'w') { |f| f.write(ead) }
        index(file)
      end
    end

    private

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

    def solr_escape(string)
      RSolr.solr_escape(string)
    end

    def update_eadid(xml, eadid)
      eadid = xml.at_css 'eadid'
      eadid.content = identifier
    end

  end

end
