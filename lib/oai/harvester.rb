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
        ENV.fetch('OAI_ENDPOINT'),
        logger: logger,
        timeout: ENV.fetch('OAI_TIMEOUT', '300').to_i
      )

      begin
        oai.identifiers(metadata_prefix: prefix, from: since).each do |header|
          identifier = header.identifier
          unless manager.valid_identifier?(identifier)
            logger.info("Identifier not matched: #{identifier}")
            next
          end
          begin
            logger.info("Harvesting: #{identifier}")
            record = oai.get(identifier, metadata_prefix: prefix)

            repository = OAI::Utils.repository(record: record)
            repository_id = manager.find_repository_id_for(repository)
            unless repository_id
              logger.info("Repository not found: #{repository}")
              next
            end

            id = "#{repository_id}_#{XXhash.xxh32(identifier)}"
            OAI::Utils.update_eadid(record: record, eadid: id)
            yield record, repository_id
          rescue StandardError => ex
            logger.error("Error harvesting [#{identifier}]: #{ex.message}")
            next
          end
        end
      rescue Fieldhand::NoRecordsMatchError
        logger.info("No repository updates since: #{since} for #{oai.uri}")
      end
    end
    # rubocop:enable Metrics/AbcSize,Metrics/MethodLength

    def yesterday
      Date.today.prev_day.to_s
    end
  end
end
