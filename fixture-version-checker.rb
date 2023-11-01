#!/usr/bin/env ruby

$LOAD_PATH << File.expand_path(File.dirname(__FILE__))

require 'httparty'
require 'optparse'
require 'ostruct'
require 'yaml'
require 'forge_client'
require 'option_parser'
require 'utilities'

options = OptionParser.parse(ARGV, 'fixtures')

if options.fixturesfile == ''
  puts 'No fixture file to analyze!'
  exit 1
end

# puts sprintf("%-40s %10s %10s %s\n", ' ',
#             'Puppetfile', 'Forge', '')
puts sprintf("%-40s %10s %10s %s\n",
  'Puppet Module', 'Version', 'Version', 'deprecated' )

filecontent = YAML.load_file(options.fixturesfile)
forge_modules = filecontent['fixtures']['forge_modules']
forge_modules.each do |mod, mod_data|
  repo = mod_data['repo']
  repo = repo.sub('/', '-')
  ref = mod_data['ref']
  data        = ForgeClient.get_current_module_data(repo)
  cur_version = data[:version]
  deprecated  = data[:deprecated]
  puts sprintf("%-40s %10s %10s %s\n", repo, ref, cur_version, deprecated)
  # puts "#{mod} - #{ref}/#{cur_version} (deprecated = #{deprecated})"
end
