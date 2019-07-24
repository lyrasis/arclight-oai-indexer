# frozen_string_literal: true

namespace :arclight do
  namespace :download do
    desc 'Download oai retrieved records'
    task :oai, [:since] do |_t, args|
      logger = Logger.new(STDOUT)
      FileUtils.mkdir_p 'downloads'
      manager = Repository::Manager.new(
        excludes: ENV.fetch('REPO_EXCLUDES', nil),
        includes: ENV.fetch('REPO_INCLUDES', nil)
      )

      harvester = OAI::Harvester.new(manager: manager)
      harvester.logger = logger
      harvester.since  = args[:since] unless args[:since].nil?

      harvester.harvest do |record|
        identifier = record.identifier
        logger.info("Downloading: #{identifier}")
        filename = identifier.gsub(%r{/}, '_').squeeze('_')
        ead      = OAI::Utils.ead(record: record)
        File.open(File.join('downloads', "#{filename}.xml"), 'w') do |f|
          f.write ead
        end
        logger.info("Downloaded: #{filename}")
      end
    end
  end
end
