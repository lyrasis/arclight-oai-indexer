module Utils

  module File

    def self.write(filename: 'ead.xml', content: nil)
      file = ::File.join(Dir.tmpdir, filename)
      ::File.open(file, 'w') { |f| f.write(content) }
      file
    end

  end

end
