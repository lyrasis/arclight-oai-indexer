# frozen_string_literal: true

namespace :arclight do
  namespace :solr do
    desc 'Delete a record by eadid'
    task :delete, [:eadid] do |_t, args|
      logger = Logger.new(STDOUT)
      eadid  = args[:eadid]
      raise 'No eadid marked for deletion' unless eadid

      solr = Solr::Client.new(
        endpoint: ENV.fetch('SOLR_URL'),
        logger: logger
      )
      logger.info("Deleting: #{eadid}")
      solr.delete(eadid: eadid)
      logger.info("Deleted: #{eadid}")
    end
  end
end
