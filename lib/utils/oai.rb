module Utils
  module OAI
    PATH_TO_EAD   = 'metadata[0]/ead[0]'.freeze
    PATH_TO_EADID = "#{PATH_TO_EAD}/eadheader[0]/eadid[0]".freeze

    def self.ead(record: nil)
      record.element.locate(PATH_TO_EAD).map do |ead|
        Ox.dump(ead, encoding: 'utf-8', indent: -1)
      end.first
    end

    def self.eadid(record: nil)
      record.element.locate(PATH_TO_EADID).map(&:text).first
    end

    def self.update_eadid(record: nil, eadid: nil)
      element = record.element.locate(PATH_TO_EADID).first
      element.replace_text(eadid) if element
    end
  end
end
