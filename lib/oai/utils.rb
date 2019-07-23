# frozen_string_literal: true

module OAI
  module Utils
    PATH_TO_EAD   = 'metadata[0]/ead[0]'
    PATH_TO_EADID = "#{PATH_TO_EAD}/eadheader[0]/eadid[0]"
    PATH_TO_REPO  = "#{PATH_TO_EAD}/archdesc[0]/did[0]/repository[0]/corpname[0]" # rubocop:disable Metrics/LineLength

    def self.ead(record: nil)
      record.element.locate(PATH_TO_EAD).map do |ead|
        Ox.dump(ead, encoding: 'utf-8', indent: -1)
      end.first
    end

    def self.eadid(record: nil)
      record.element.locate(PATH_TO_EADID).map(&:text).first
    end

    def self.repository(record: nil)
      record.element.locate(PATH_TO_REPO).map(&:text).first
    end

    def self.update_eadid(record: nil, eadid: nil)
      element = record.element.locate(PATH_TO_EADID).first
      element&.replace_text(eadid)
    end
  end
end
