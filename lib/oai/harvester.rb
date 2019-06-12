# frozen_string_literal: true

require 'date'
require 'fieldhand'

module OAI
  module Harvester
    def self.harvest(since: yesterday, logger: Logger.new(STDOUT))
      oai = Fieldhand::Repository.new(
        ENV.fetch('OAI_ENDPOINT'),
        logger: logger,
        timeout: 300
      )

      begin
        oai.records(metadata_prefix: 'oai_ead', from: since).each do |record|
          yield record
        end
      rescue Fieldhand::NoRecordsMatchError
        logger.info("No record updates since: #{since} for #{oai.uri}")
      end
    end

    def self.yesterday
      Date.today.prev_day.to_s
    end
  end
end
