# frozen_string_literal: true

namespace :arclight do
  namespace :download do
    desc 'Download oai retrieved records'
    task :oai, [:since, :prefix] do |_t, args|
      logger = Logger.new(STDOUT)
      FileUtils.mkdir_p 'downloads'
      manager = Repository::Manager.new(
        excludes: ENV.fetch('REPO_EXCLUDES', nil),
        includes: ENV.fetch('REPO_INCLUDES', nil)
      )

      harvester = OAI::Harvester.new(manager: manager)
      harvester.logger = logger
      harvester.since  = args[:since] unless args[:since].nil?
      harvester.prefix = args[:prefix] ||= 'oai_ead'

      harvester.harvest do |record|
        identifier = record.identifier
        logger.info("Downloading: #{identifier}")
        filename = identifier.gsub(%r{/}, '_').squeeze('_')

        content = OAI::Utils.send(harvester.prefix, record: record)

        File.open(File.join('downloads', "#{filename}.xml"), 'w') do |f|
          f.write content
        end
        logger.info("Downloaded: #{filename}")
      end
    end
  end
end
