# frozen_string_literal: true

module Fieldhand
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
