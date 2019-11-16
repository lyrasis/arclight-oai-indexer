# frozen_string_literal: true

namespace :arclight do
  namespace :index do
    # bundle exec rake arclight:index:dir[/path/to/dir]
    desc 'Index EAD files from a directory'
    task :dir, [:dir] do |_t, args|
      dir = args[:dir]
      raise "Directory not found: #{dir}" unless File.directory?(dir)

      Dir["#{dir}/*.xml"].each do |file|
        Rake::Task['arclight:index:file'].invoke(file)
        Rake::Task['arclight:index:file'].reenable
      end
    end

    # bundle exec rake arclight:index:file[/path/to/file]
    desc 'Index an EAD file'
    task :file, [:file] do |_t, args|
      file = args[:file]
      raise "File not found: #{file}" unless File.file?(file)

      manager = Repository::Manager.new(
        repositories: ENV.fetch('REPOSITORY_URL')
      )

      doc = Nokogiri::XML(File.open(file))
      repository = XML::Utils.repository(doc: doc)
      repository_id = manager.find_repository_id_for(repository)
      ENV['REPOSITORY_ID'] = repository_id
      Solr::Client.index(file: file)
      FileUtils.mv file, "#{file}.bak"
    end

    # bundle exec rake arclight:index:oai
    desc 'Index EAD records from an OAI endpoint'
    task :oai, [:since] do |_t, args|
      logger = Logger.new(STDOUT)
      index_files = {}
      manager = Repository::Manager.new(
        repositories: ENV.fetch('REPOSITORY_URL')
      )

      harvester = OAI::Harvester.new(manager: manager)
      harvester.logger = logger
      harvester.since  = args[:since] unless args[:since].nil?

      harvester.harvest do |record, repository_id|
        identifier = record.identifier
        if !record.deleted?
          filename = identifier.gsub(%r{/}, '_').squeeze('_')
          ead      = OAI::Utils.oai_ead(record: record)
          index_files[identifier] = {
            file: File::Utils.cache(filename: filename, content: ead),
            repository_id: repository_id
          }
          logger.info("Harvested: #{filename}")
        else
          Solr::Client.delete(eadid: identifier)
        end
      end

      index_files.each do |_, attributes|
        ENV['REPOSITORY_ID'] = attributes[:repository_id]
        Solr::Client.index(file: attributes[:file])
        FileUtils.rm(attributes[:file], force: true)
      end
    end

    desc 'Index an EAD record from a url'
    task :url, [:url] do |_t, args|
      url = args[:url]
      raise 'No url specified for indexing' unless url

      Rake::Task['arclight:index:file'].invoke(
        File::Utils.cache(content: HTTP.get(url))
      )
    end
  end
end
