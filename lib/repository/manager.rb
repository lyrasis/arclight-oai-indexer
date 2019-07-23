# frozen_string_literal: true

module Repository
  class Manager
    def initialize(excludes: nil, includes: nil)
      @excludes = excludes ? excludes.split(',') : nil
      @includes = includes ? includes.split(',') : nil
    end

    def exclude?(repository)
      return false unless @excludes

      @excludes.include?(repository)
    end

    def include?(repository)
      return true unless @includes

      @includes.include?(repository)
    end
  end
end
