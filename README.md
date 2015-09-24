# dokku elasticsearch (beta) [![Build Status](https://img.shields.io/travis/dokku/dokku-elasticsearch.svg?branch=master "Build Status")](https://travis-ci.org/dokku/dokku-elasticsearch) [![IRC Network](https://img.shields.io/badge/irc-freenode-blue.svg "IRC Freenode")](https://webchat.freenode.net/?channels=dokku)

Official elasticsearch plugin for dokku. Currently defaults to installing [elasticsearch 1.7.1](https://hub.docker.com/_/elasticsearch/).

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
elasticsearch:alias <name> <alias>     Set an alias for the docker link
elasticsearch:clone <name> <new-name>  NOT IMPLEMENTED
elasticsearch:connect <name>           NOT IMPLEMENTED
elasticsearch:create <name>            Create a elasticsearch service
elasticsearch:destroy <name>           Delete the service and stop its container if there are no links left
elasticsearch:export <name>            NOT IMPLEMENTED
elasticsearch:expose <name> [port]     Expose a elasticsearch service on custom port if provided (random port otherwise)
elasticsearch:import <name> <file>     NOT IMPLEMENTED
elasticsearch:info <name>              Print the connection information
elasticsearch:link <name> <app>        Link the elasticsearch service to the app
elasticsearch:list                     List all elasticsearch services
elasticsearch:logs <name> [-t]         Print the most recent log(s) for this service
elasticsearch:restart <name>           Graceful shutdown and restart of the elasticsearch service container
elasticsearch:start <name>             Start a previously stopped elasticsearch service
elasticsearch:stop <name>              Stop a running elasticsearch service
elasticsearch:unexpose <name>          Unexpose a previously exposed elasticsearch service
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
dokku elasticsearch:create lolipop

# get connection information as follows
dokku elasticsearch:info lolipop

# lets assume the ip of our elasticsearch service is 172.17.0.1

# a elasticsearch service can be linked to a
# container this will use native docker
# links via the docker-options plugin
# here we link it to our 'playground' app
# NOTE: this will restart your app
dokku elasticsearch:link lolipop playground

# the above will expose the following environment variables
#
#   ELASTICSEARCH_URL=http://172.17.0.1:9200
#   ELASTICSEARCH_NAME=/random_name/ELASTICSEARCH
#   ELASTICSEARCH_PORT=tcp://172.17.0.1:9200
#   ELASTICSEARCH_PORT_9200_TCP=tcp://172.17.0.1:9200
#   ELASTICSEARCH_PORT_9200_TCP_PROTO=tcp
#   ELASTICSEARCH_PORT_9200_TCP_PORT=9200
#   ELASTICSEARCH_PORT_9200_TCP_ADDR=172.17.0.1

# you can examine the environment variables
# using our 'playground' app's env command
dokku run playground env

# you can customize the prefix of environment
# variables through a custom docker link alias
dokku elasticsearch:alias lolipop DATABASE

# you can also unlink a elasticsearch service
# NOTE: this will restart your app
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
