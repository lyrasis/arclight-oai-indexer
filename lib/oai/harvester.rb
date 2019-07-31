# frozen_string_literal: true

require 'date'
require 'fieldhand'

module OAI
  class Harvester
    attr_accessor :logger, :prefix, :since
    attr_reader :manager

    def initialize(manager: Repository::Manager.new)
      @logger  = Logger.new(STDOUT)
      @manager = manager
      @prefix  = default_prefix
      @since   = yesterday
    end

    def default_prefix
      'oai_ead'
    end

    # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
    def harvest
      oai = Fieldhand::Repository.new(
        ENV.fetch('OAI_ENDPOINT'), logger: logger, timeout: 300
      )

      begin
        oai.records(metadata_prefix: prefix, from: since).each do |record|
          if prefix != default_prefix
            yield record
            next
          end

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
