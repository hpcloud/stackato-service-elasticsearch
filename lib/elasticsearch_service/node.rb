require 'fileutils'
require 'logger'
require 'uuidtools'
require 'data_mapper'
require 'elasticsearch'

module VCAP
  module Services
    module Elasticsearch
      class Node < VCAP::Services::Base::Node
      end
    end
  end
end

require 'elasticsearch_service/common'
require 'elasticsearch_service/error'

class VCAP::Services::Elasticsearch::Node

  include VCAP::Services::Elasticsearch::Common
  include VCAP::Services::Elasticsearch

  # A database class for saving node instances to the config. See http://datamapper.org/
  # for more details on the DataMapper gem. For the example service, we only want to
  # save the name.
  class ProvisionedService
    include DataMapper::Resource
    property :name,       String,       :key => true
  end

  # constructor. Calls VCAP::Services::Base::Node's constructor,
  # then does some custom config stuff for this node here.
  def initialize(options)
    super(options)
    @port = options[:port]
    @base_dir = options[:base_dir]
    @local_db = options[:local_db]
    @client = Elasticsearch::Client.new log: true
  end

  # place here anything you want to do before the service announces
  # that it is ready to take requests
  def pre_send_announcement
    # let the base node class do its stuff
    super()
    # create the base directory for our services. all data such as pidfiles
    # and logs should be placed in @base_dir/:service_name
    FileUtils.mkdir_p(@base_dir) if @base_dir
    start_db()
    # if we have provisioned services in the database, we want to make sure
    # that we won't go over our capacity limit!
    @capacity_lock.synchronize do
      ProvisionedService.all.each do |instance|
        @capacity -= capacity_unit
      end
    end
  end

  # an announcement that we are ready to take requests from the gateway. enter
  # any data here that you think would be relevant for the gateway to know about
  def announcement
    # do some race checking
    @capacity_lock.synchronize do
      { :available_capacity => @capacity,
        :capacity_unit => capacity_unit }
    end
  end

  # configure the database and set it up
  def start_db
    @logger.debug("starting database")
    DataMapper.setup(:default, @local_db)
    DataMapper::auto_upgrade!
  end

  # provision a service node. This could mean to create a new database,
  # spawn a new process, or something completely different.
  def provision(plan, credential = nil, version=nil)
    instance = ProvisionedService.new
    instance.name = credential ? credential["name"] : UUIDTools::UUID.random_create.to_s

    @logger.debug("Provisioning elasticsearch instance: #{instance.name}")

    # do the provisioning code in here, as well as saving the
    # information into the database
    @client.indices.create index: instance.name
    save_instance(instance)
    return gen_credential(instance.name, get_host, @port)
  end

  # deprovision a service node. Drop a database, kill a process, or do something else.
  # this could also be empty if nothing needs to be done, in which case just return true.
  def unprovision(name, credentials = [])
    @logger.debug("Unprovisioning elasticsearch service: #{name}")
    instance = get_instance(name)
    # check to make sure that the user is not trying to delete all indices
    @client.indices.delete index: instance.name unless instance.name == '_all'
    destroy_instance(instance)
    return true
  end

  # a bind request will usually grant a user access to the service created earlier.
  # in the context of databases, this usually means to create a random username
  # and password, and to create a user for that database with the correct
  # read/write permissions.
  def bind(name, binding_options, credential = nil)
    instance = credential ? get_instance(credential["name"]) : get_instance(name)
    return gen_credential(instance.name, get_host, @port)
  end

  # do the exact opposite of a bind request
  def unbind(credential)
    @logger.debug("Unbinding service: #{credential.inspect}")
    return true
  end

  # save the node instance details into the database. Call this any time
  # you update something for the instance 
  def save_instance(instance)
    raise ElasticsearchError.new(ElasticsearchError::SAVE_INSTANCE_FAILED, instance.inspect) unless instance.save
  end

  # destroys the node instance details in the database
  def destroy_instance(instance)
    raise ElasticsearchError.new(ElasticsearchError::DESTROY_INSTANCE_FAILED, instance.inspect) unless instance.destroy
  end

  # searches the database for the service identified by name
  def get_instance(name)
    instance = ProvisionedService.get(name)
    raise ElasticsearchError.new(ElasticsearchError::FIND_INSTANCE_FAILED, name) if instance.nil?
    return instance
  end

  # returns the binding credentials for this node instance.
  # this information will be sent to the cloud controller
  # for notifying the user where to access this service.
  def gen_credential(name, host, port)
    return ({
      "host" => host,
      "port" => port,
      "name" => name,
      "uri" => "http://#{host}:#{port}/"
    })
  end

  # gets the hostname where this service runs on.
  # @local_ip comes from the base class.
  def get_host
    return @local_ip
  end
end
