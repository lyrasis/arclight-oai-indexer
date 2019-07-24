# frozen_string_literal: true

require 'date'
require 'fieldhand'

module OAI
  class Harvester
    attr_accessor :logger, :since
    attr_reader :manager

    def initialize(manager: Repository::Manager.new)
      @logger  = Logger.new(STDOUT)
      @manager = manager
      @since   = yesterday
    end

    # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
    def harvest
      oai = Fieldhand::Repository.new(
        ENV.fetch('OAI_ENDPOINT'), logger: logger, timeout: 300
      )

      begin
        oai.records(metadata_prefix: 'oai_ead', from: since).each do |record|
          identifier = record.identifier
          repository = OAI::Utils.repository(record: record)
          if manager.exclude?(repository) || !manager.include?(repository)
            logger.info("Skipping repository: #{repository}, #{identifier}")
            next
          end
          OAI::Utils.update_eadid(record: record, eadid: identifier)
          yield record
        end
      rescue Fieldhand::NoRecordsMatchError
        logger.info("No record updates since: #{since} for #{oai.uri}")
      end
    end
    # rubocop:enable Metrics/AbcSize,Metrics/MethodLength

    def yesterday
      Date.today.prev_day.to_s
    end
  end
end
