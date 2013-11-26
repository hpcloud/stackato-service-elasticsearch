require 'elasticsearch_service/common'

class VCAP::Services::Elasticsearch::Provisioner < VCAP::Services::Base::Provisioner
  include VCAP::Services::Elasticsearch::Common
end
