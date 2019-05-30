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

require_relative 'lib/arclight/indexer'
require_relative 'lib/solr/client'
require_relative 'lib/utils/file'
require_relative 'lib/utils/oai'
