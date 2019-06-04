# frozen_string_literal: true

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

  class ResponseParser
    # https://github.com/fieldhand/fieldhand/blob/master/lib/fieldhand/response_parser.rb#L56
    def root
      @root ||= ::Ox.load(
        response,
        effort: :tolerant,
        smart: true,
        strip_namespace: 'oai'
      ).root
    end
  end
end