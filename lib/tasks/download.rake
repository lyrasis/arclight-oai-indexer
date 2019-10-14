# frozen_string_literal: true

namespace :arclight do
  namespace :download do
    desc 'Download oai retrieved records'
    task :oai, [:since, :prefix] do |_t, args|
      logger = Logger.new(STDOUT)
      FileUtils.mkdir_p 'downloads'
      manager = Repository::Manager.new(
        repositories: ENV.fetch('REPOSITORY_URL')
      )

      harvester = OAI::Harvester.new(manager: manager)
      harvester.logger = logger
      harvester.since  = args[:since] unless args[:since].nil?
      harvester.prefix = args[:prefix] ||= 'oai_ead'

      harvester.harvest do |record, _|
        identifier = record.identifier
        filename = identifier.gsub(%r{/}, '_').squeeze('_')

        content = OAI::Utils.send(harvester.prefix, record: record)

        File.open(File.join('downloads', "#{filename}.xml"), 'w') do |f|
          f.write content
        end
        logger.info("Harvested: #{filename}")
      end
    end
  end
end
