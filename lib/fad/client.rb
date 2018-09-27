module FAD

  class Client

    attr_reader :config, :indexer, :solr

    def self.get_config(restricted: false)
      {
        env: ENV['FAD_ENV'],
        restricted: restricted,
        token: ENV['FAD_TOKEN'],
        url: ENV['FAD_URL'],
        site: ENV['REPOSITORY_ID'],
        solr_url: ENV['SOLR_URL'],
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
      construct_url = File.join(
        config[:url],
        config[:env],
        config[:site],
        "resources?since=#{since}"
      )
      parse_url(construct_url)
    end

    def construct_resource_endpoint(url: nil)
      construct_url = File.join(
        config[:url],
        config[:env],
        config[:site],
        'resources',
        "find?url=#{url}"
      )
      parse_url(construct_url)
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

    def download(url: nil, restricted: false)
      if restricted
        HTTP['x-api-key' => config[:token]]
          .get(construct_resource_endpoint(url: url))
      else
        HTTP.get(url)
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

    def update(records: [])
      elapsed_time = 0
      records.each do |record|
        record_url = record['url']
        ead = Nokogiri::XML(download(url: record_url, restricted: config[:restricted]).body)
        update_eadid(ead, record_url)
        elapsed_time += index(file: write_to_file(content: ead))
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

    def update_eadid(xml, identifier)
      eadid = xml.at_css 'eadid'
      eadid.content = identifier
    end

  end

end
