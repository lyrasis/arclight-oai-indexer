# frozen_string_literal: true

module Repository
  class Manager
    attr_reader :file, :repositories
    def initialize(repositories:)
      @repositories = download(repositories)
      @file = File::Utils.cache(
        filename: 'repositories.yml',
        content: @repositories.to_yaml
      )
      ENV['REPOSITORY_FILE'] = @file
    end

    def valid_identifier?(identifier)
      repositories.find do |_, repo|
        identifier.start_with?(repo['identifier_prefix'])
      end
    end

    def download(repositories)
      YAML.safe_load(HTTP.get(repositories).to_s)
    end

    def find_repository_id_for(repository)
      id = repositories.find { |_, repo| repo['name'] == repository }
      id.nil? ? nil : id.first
    end
  end
end
