# frozen_string_literal: true

namespace :arclight do
  namespace :index do
    # bundle exec rake arclight:index:dir[/path/to/dir]
    desc 'Index EAD files from a directory'
    task :dir, [:dir] do |_t, args|
      dir = args[:dir]
      raise "Directory not found: #{dir}" unless File.directory?(dir)

      Dir["#{dir}/*.xml"].each do |file|
        Solr::Client.index(file: file)
        FileUtils.mv file, "#{file}.bak"
      end
    end

    # bundle exec rake arclight:index:file[/path/to/file]
    desc 'Index an EAD file'
    task :file, [:file] do |_t, args|
      file = args[:file]
      raise "File not found: #{file}" unless File.file?(file)

      Solr::Client.index(file: file)
    end

    # bundle exec rake arclight:index:oai
    desc 'Index EAD records from an OAI endpoint'
    task :oai, [:since] do |_t, args|
      logger = Logger.new(STDOUT)
      since  = args[:since] ||= yesterday
      index_files = []

      OAI::Harvester.harvest(since: since, logger: logger) do |record|
        identifier = record.identifier
        if !record.deleted?
          logger.info("Downloading: #{identifier}")
          Utils::OAI.update_eadid(record: record, eadid: identifier)
          filename = identifier.gsub(%r{/}, '_').squeeze('_')
          ead      = Utils::OAI.ead(record: record)
          index_files << Utils::File.cache(filename: filename, content: ead)
          logger.info("Downloaded: #{index_files[-1]}")
        else
          Solr::Client.delete(eadid: identifier)
        end
      end

      index_files.each do |file|
        Solr::Client.index(file: file)
        FileUtils.rm(file, force: true)
      end
    end

    desc 'Index an EAD record from a url'
    task :url, [:url] do |_t, args|
      url = args[:url]
      raise 'No url specified for indexing' unless url

      Solr::Client.index(file: Utils::File.cache(content: HTTP.get(url).body))
    end
  end
end
