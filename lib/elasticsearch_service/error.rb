module VCAP
  module Services
    module Elasticsearch
      class ElasticsearchError < VCAP::Services::Base::Error::ServiceError
        FIND_INSTANCE_FAILED    = [32100, HTTP_INTERNAL, "Could not find instance: %s"]
        SAVE_INSTANCE_FAILED    = [32101, HTTP_INTERNAL, "Could not save instance: %s"]
        DESTROY_INSTANCE_FAILED = [32102, HTTP_INTERNAL, "Could not destroy instance: %s"]
      end
    end
  end
end
