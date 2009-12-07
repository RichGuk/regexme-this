require 'rubygems'
require 'haml'
require 'json'
require 'sinatra' unless defined?(Sinatra)

Dir[File.join(File.dirname(__FILE__), 'lib', '*.rb')].each do |f|
  require f
end

set :haml, {:attr_wrapper => '"'}