# frozen_string_literal: true

require 'arclight'
require 'benchmark'
require 'dotenv/load'
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

Dir.glob('lib/*/*.rb').each { |r| require_relative r }
Dir.glob('lib/tasks/*.rake').each { |r| load r }
