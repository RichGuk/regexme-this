require File.join(File.dirname(__FILE__), '..', 'application')

require 'spec'
require 'rack/test'

set :environment, :test
set :logging, false

Spec::Runner.configure do |config|
  config.include Rack::Test::Methods
end