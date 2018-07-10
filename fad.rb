# frozen_string_literal: true

##
# Environment variables for indexing (c.f. index.rb):
#
# FAD_URL base url to FAD api endpoint (default: none).
#
# FAD_ENV the deployment stage of the api (default: none).
#
# FAD_TOKEN access token (default: none).
#
namespace :arclight do
  desc 'Index resources via a FAD API endpoint'
  task :index_fad do
    # TODO:
    # *. sync config/repositories.yml using ENV.fetch('REPOSITORY_URL')
    # *. check ENV.fetch('REPOSITORY_ID') is valid (is in list of repos)
    # *. get list of resources from fad
    # *. remove deleted records from index (new task required?)
    # *. use arclight:index_url to ingest updated records
    puts "Coming soon!"
  end
end
