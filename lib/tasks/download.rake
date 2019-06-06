# frozen_string_literal: true

namespace :arclight do
  namespace :download do
    desc 'Download oai retrieved records'
    task :oai, [:since] do |_t, args|
      logger = Logger.new(STDOUT)
      since  = args[:since] ||= yesterday
      FileUtils.mkdir_p 'downloads'
      OAI::Harvester.harvest(since: since, logger: logger) do |eadid, record|
        logger.info("Downloading: #{eadid}")
        filename = eadid.gsub(%r{/}, '_').squeeze('_')
        ead      = Utils::OAI.ead(record: record)
        File.open(File.join('downloads', "#{filename}.xml"), 'w') do |f|
          f.write ead
        end
        logger.info("Downloaded: #{filename}")
      end
    end
  end
end
