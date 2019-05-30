# frozen_string_literal: true

module Utils
  module File
    # writes content to file and returns path
    def self.cache(filename: 'ead.xml', content: nil)
      file = ::File.join(Dir.tmpdir, filename)
      ::File.open(file, 'w') do |f|
        f.write(content)
      end
      file
    end
  end
end
