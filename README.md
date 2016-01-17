# dokku elasticsearch (beta) [![Build Status](https://img.shields.io/travis/dokku/dokku-elasticsearch.svg?branch=master "Build Status")](https://travis-ci.org/dokku/dokku-elasticsearch) [![IRC Network](https://img.shields.io/badge/irc-freenode-blue.svg "IRC Freenode")](https://webchat.freenode.net/?channels=dokku)

Official elasticsearch plugin for dokku. Currently defaults to installing [elasticsearch 2.1.1](https://hub.docker.com/_/elasticsearch/).

## requirements

- dokku 0.4.0+
- docker 1.8.x

## installation

```shell
# on 0.3.x
cd /var/lib/dokku/plugins
git clone https://github.com/dokku/dokku-elasticsearch.git elasticsearch
dokku plugins-install

# on 0.4.x
dokku plugin:install https://github.com/dokku/dokku-elasticsearch.git elasticsearch
```

## commands

```
elasticsearch:clone <name> <new-name>  NOT IMPLEMENTED
elasticsearch:connect <name>           NOT IMPLEMENTED
elasticsearch:create <name>            Create a elasticsearch service with environment variables
elasticsearch:destroy <name>           Delete the service and stop its container if there are no links left
elasticsearch:export <name> > <file>   NOT IMPLEMENTED
elasticsearch:expose <name> [port]     Expose a elasticsearch service on custom port if provided (random port otherwise)
elasticsearch:import <name> <file>     NOT IMPLEMENTED
elasticsearch:info <name>              Print the connection information
elasticsearch:link <name> <app>        Link the elasticsearch service to the app
elasticsearch:list                     List all elasticsearch services
elasticsearch:logs <name> [-t]         Print the most recent log(s) for this service
elasticsearch:promote <name> <app>     Promote service <name> as ELASTICSEARCH_URL in <app>
elasticsearch:restart <name>           Graceful shutdown and restart of the elasticsearch service container
elasticsearch:start <name>             Start a previously stopped elasticsearch service
elasticsearch:stop <name>              Stop a running elasticsearch service
elasticsearch:unexpose <name>          Unexpose a previously exposed elasticsearch service
elasticsearch:unlink <name> <app>      Unlink the elasticsearch service from the app
```

## usage

```shell
# create a elasticsearch service named lolipop
dokku elasticsearch:create lolipop

# you can also specify the image and image
# version to use for the service
# it *must* be compatible with the
# official elasticsearch image
export ELASTICSEARCH_IMAGE="elasticsearch"
export ELASTICSEARCH_IMAGE_VERSION="1.6.2"

# you can also specify custom environment
# variables to start the elasticsearch service
# in semi-colon separated forma
export ELASTICSEARCH_CUSTOM_ENV="USER=alpha;HOST=beta"

# create a elasticsearch service
dokku elasticsearch:create lolipop

# get connection information as follows
dokku elasticsearch:info lolipop

# a elasticsearch service can be linked to a
# container this will use native docker
# links via the docker-options plugin
# here we link it to our 'playground' app
# NOTE: this will restart your app
dokku elasticsearch:link lolipop playground

# the following environment variables will be set automatically by docker (not
# on the app itself, so they won’t be listed when calling dokku config)
#
#   DOKKU_ELASTICSEARCH_LOLIPOP_NAME=/random_name/ELASTICSEARCH
#   DOKKU_ELASTICSEARCH_LOLIPOP_PORT=tcp://172.17.0.1:9200
#   DOKKU_ELASTICSEARCH_LOLIPOP_PORT_9200_TCP=tcp://172.17.0.1:9200
#   DOKKU_ELASTICSEARCH_LOLIPOP_PORT_9200_TCP_PROTO=tcp
#   DOKKU_ELASTICSEARCH_LOLIPOP_PORT_9200_TCP_PORT=9200
#   DOKKU_ELASTICSEARCH_LOLIPOP_PORT_9200_TCP_ADDR=172.17.0.1
#
# and the following will be set on the linked application by default
#
#   ELASTICSEARCH_URL=http://dokku-elasticsearch-lolipop:9200
#
# NOTE: the host exposed here only works internally in docker containers. If
# you want your container to be reachable from outside, you should use `expose`.

# another service can be linked to your app
dokku elasticsearch:link other_service playground

# since ELASTICSEARCH_URL is already in use, another environment variable will be
# generated automatically
#
#   DOKKU_ELASTICSEARCH_BLUE_URL=http://dokku-elasticsearch-other-service:9200

# you can then promote the new service to be the primary one
# NOTE: this will restart your app
dokku elasticsearch:promote other_service playground

# this will replace ELASTICSEARCH_URL with the url from other_service and generate
# another environment variable to hold the previous value if necessary.
# you could end up with the following for example:
#
#   ELASTICSEARCH_URL=http://dokku-elasticsearch-other-service:9200
#   DOKKU_ELASTICSEARCH_BLUE_URL=http://dokku-elasticsearch-other-service:9200
#   DOKKU_ELASTICSEARCH_SILVER_URL=http://dokku-elasticsearch-lolipop:9200

# you can also unlink an elasticsearch service
# NOTE: this will restart your app and unset related environment variables
dokku elasticsearch:unlink lolipop playground

# you can tail logs for a particular service
dokku elasticsearch:logs lolipop
dokku elasticsearch:logs lolipop -t # to tail

# finally, you can destroy the container
dokku elasticsearch:destroy lolipop
```

## todo

- implement elasticsearch:clone
- implement elasticsearch:import
