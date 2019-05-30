# frozen_string_literal: true

require 'arclight'
require 'benchmark'
require 'dotenv/load'
require 'fieldhand'
require 'fileutils'
require 'http'
require 'logger'
require 'nokogiri'
require 'rsolr'
require 'tmpdir'
require 'uri'
require 'yaml'

require_relative 'lib/arclight/indexer'
require_relative 'lib/solr/client'
require_relative 'lib/utils/file'
require_relative 'lib/utils/oai'

module Fieldhand
  class Paginator
    # https://github.com/fieldhand/fieldhand/issues/17
    def items(verb, parser_class, query = {}) # rubocop:disable all
      return enum_for(:items, verb, parser_class, query) unless block_given?

      redos = 0
      loop do
        begin
          response_parser = parse_response(query.merge('verb' => verb))
        rescue ResponseError => e
          redos += 1
          if redos < 10 # rubocop:disable Style/GuardClause
            delay = redos * redos
            logger.warn('Fieldhand') do
              "Response error #{e}\nRetrying in #{delay} seconds"
            end
            sleep delay
            redo
          else
            raise e
          end
        end
        parser_class.new(response_parser).items.each do |item|
          yield item
        end

        break unless response_parser.resumption_token

        logger.debug('Fieldhand') do
          "Resumption token for #{verb}: #{response_parser.resumption_token}"
        end
        query = { 'resumptionToken' => response_parser.resumption_token }
      end
    end
  end
end
