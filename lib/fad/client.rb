module FAD

  class Client

    attr_reader :config, :indexer, :solr

    def self.get_config
      {
        token: ENV['FAD_TOKEN'],
        url: ENV['FAD_URL'],
        env: ENV['FAD_ENV'],
        site: ENV['REPOSITORY_ID'],
        solr_url: ENV['SOLR_URL']
      }
    end

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
      elapsed_time = 0
      records.each do |record|
        elapsed_time += destroy(eadid: record['url'])
      end
      elapsed_time
    end

    def destroy(eadid: nil)
      Benchmark.realtime do
        solr.get(
          'select',
          params: {
            q: solr.delete_by_query("ead_ssi:#{solr_escape(eadid)}")
          }
        )
        solr.commit
      end
    end

    def index(file: nil)
      Benchmark.realtime do
        indexer.update(file)
      end
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
      elapsed_time = 0
      records.each do |record|
        record_url = record['url']
        ead = Nokogiri::XML(record(url: record_url).body)
        update_eadid(ead, record_url)
        elapsed_time += index(write_to_file(content: ead))
      end
      elapsed_time
    end

    def write_to_file(filename: 'fad.xml', content: nil)
      file = File.join(Dir.tmpdir, filename)
      File.open(file, 'w') { |f| f.write(content) }
      file
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
