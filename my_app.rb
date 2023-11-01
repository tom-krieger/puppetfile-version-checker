$LOAD_PATH << File.expand_path(File.dirname(__FILE__))

require './lib/swaggering'
require 'httparty'
require 'ostruct'
require 'stringio'
require 'zip'
require './classes/puppet_file_check'
require './utilities'
require './forge_client'
require 'tempfile'
require 'pp'

# only need to extend if you want special configuration!
class MyApp < Swaggering
  self.configure do |config|
    config.api_version = '1.0.0' 
  end
end

# include the api files
Dir["./api/*.rb"].each { |file|
  require file
}
