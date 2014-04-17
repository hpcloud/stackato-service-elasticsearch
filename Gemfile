source 'https://rubygems.org'

# the node/service architecture is built with sinatra
gem 'sinatra', '1.3.6'

# ...and hosted by Thin.
gem 'thin', '1.5.1'

# used to generate UUIDs for service names
gem 'uuidtools', '2.1.4'
gem 'ruby-hmac', '0.4.0'

# an ORM for saving services to a database
gem 'datamapper', '1.2.0'
gem 'dm-sqlite-adapter', '1.2.0'
gem 'do_sqlite3', '0.10.13'

# The NATS message bus
gem 'nats', '0.5.0.beta12'

# Used to work with elasticsearch
gem 'elasticsearch', '0.4.1'

# cloudfoundry-specific gems for logging and for providing
# us with some basic foundation for our service.
gem 'vcap_common', :path => '../../common', :require => ['vcap/common', 'vcap/component']
gem 'vcap_services_base', :path => '../base'
gem 'vcap_logging', '>=0.1.3', :require => ['vcap/logging']
# stackato's vcap_common relies on eventmachine for event-based triggers
gem 'eventmachine', '1.0.3'
gem 'em-http-request', '1.0.3'

group :test do
  # we need to test our code!
  gem 'rake', '0.9.6'
  gem 'rspec', '2.14.1'
end
