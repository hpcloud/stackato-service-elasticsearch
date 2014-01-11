Elasticsearch Service for Stackato
==================================

This is the Stackato plugin to have Elasticsearch as a
first-class data service on your own cluster.

This service is based on [ActiveState/stackato-echoservice](https://github.com/ActiveState/stackato-echoservice)
with some additional scripts (e.g for `kato` and `supervisord`)
and other minor differences (e.g. the Gemfile). The instructions
here are for [Stackato v3.0 beta](http://beta.stackato.com/).

# Installing

Log in to the Stackato VM (either a micro cloud or a service node, if you are
in a clustered environment) as the stackato user and clone this repository:

    $ git clone git://github.com/ActiveState/stackato-elasticsearch-service ~/stackato-elasticsearch-service

After it's been cloned, run the following scripts that are given to you in the
`scripts/` directory:

    $ cd ~/stackato-elasticsearch-service
    $ sudo ./scripts/install-elasticsearch.sh
    $ ./scripts/bootstrap.sh

## Verify the service

Once the service has been enabled and started, you'll have to add the client
service auth token from the client to allow users to use this service:

    $ # from the service node
    $ kato config get elasticsearch_gateway token
    $ # copy this token
    $ exit
    λ # now we are on our local 'pyooter
    λ stackato create-service-auth-token elasticsearch core --auth-token <token>
    λ stackato services

    ============== Service Plans ================

    +---------------+-----------------------------------+----------+---------+------+---------+
    | Name          | Description                       | Provider | Version | Plan | Details |
    +---------------+-----------------------------------+----------+---------+------+---------+
    | elasticsearch | search and analytics engine       | core     | 0.90.7  | free | free    |
    | filesystem    | Persistent filesystem service     | core     | 1.0     | free | free    |
    | mysql         | MySQL database service            | core     | 5.5     | free | free    |
    | postgresql    | PostgreSQL database service       | core     | 9.1     | free | free    |
    +---------------+-----------------------------------+----------+---------+------+---------+

    λ st create-service elasticsearch
    1. free: free
    Please select the service plan to enact: 1
    Creating new service [elasticsearch-e76e8] ... OK

# Contributing

Please feel free to create any issues or send pull requests to this project.
