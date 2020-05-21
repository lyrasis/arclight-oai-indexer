# frozen_string_literal: true

require 'arclight'
require 'benchmark'
require 'dotenv'
require 'fieldhand'
require 'fileutils'
require 'http'
require 'logger'
require 'nokogiri'
require 'rsolr'
require 'tmpdir'
require 'uri'
require 'yaml'
require 'xxhash'

Dotenv.load('.env.local', '.env')

Dir.glob('lib/*/*.rb').each { |r| require_relative r }
Dir.glob('lib/tasks/*.rake').each { |r| load r }
