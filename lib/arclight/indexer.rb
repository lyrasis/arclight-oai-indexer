module ArcLight
  class Indexer
    def self.default_indexer(options: {})
      options = {
        document:  Arclight::CustomDocument,
        component: Arclight::CustomComponent
      }.merge(options)

      Arclight::Indexer.new(options)
    end
  end
end
