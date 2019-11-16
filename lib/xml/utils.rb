# frozen_string_literal: true

module XML
  module Utils
    PATH_TO_REPO = 'ead archdesc did repository corpname' # rubocop:disable Metrics/LineLength

    def self.repository(doc: nil)
      doc.css(PATH_TO_REPO).text
    end
  end
end
