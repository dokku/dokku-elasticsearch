# dokku elasticsearch (beta)

Official elasticsearch plugin for dokku. Currently installs elasticsearch 1.7.1.

## requirements

- dokku 0.3.25+
- docker 1.6.x

## installation

```
cd /var/lib/dokku/plugins
git clone https://github.com/dokku/dokku-elasticsearch.git elasticsearch
dokku plugins-install-dependencies
dokku plugins-install
```

## commands

```
elasticsearch:alias <name> <alias>     Set an alias for the docker link
elasticsearch:clone <name> <new-name>  NOT IMPLEMENTED
elasticsearch:connect <name>           NOT IMPLEMENTED
elasticsearch:create <name>            Create a elasticsearch service
elasticsearch:destroy <name>           Delete the service and stop its container if there are no links left
elasticsearch:export <name>            NOT IMPLEMENTED
elasticsearch:expose <name> <port>     NOT IMPLEMENTED
elasticsearch:import <name> <file>     NOT IMPLEMENTED
elasticsearch:info <name>              Print the connection information
elasticsearch:link <name> <app>        Link the elasticsearch service to the app
elasticsearch:list                     List all elasticsearch services
elasticsearch:logs <name> [-t]         Print the most recent log(s) for this service
elasticsearch:restart <name>           Graceful shutdown and restart of the service container
elasticsearch:unexpose <name> <port>   NOT IMPLEMENTED
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
#   DATABASE_URL=elasticsearch://elasticsearch:SOME_PASSWORD@172.17.0.1:9200
#   DATABASE_NAME=/playground/DATABASE
#   DATABASE_PORT=tcp://172.17.0.1:9200
#   DATABASE_PORT_9200_TCP=tcp://172.17.0.1:9200
#   DATABASE_PORT_9200_TCP_PROTO=tcp
#   DATABASE_PORT_9200_TCP_PORT=9200
#   DATABASE_PORT_9200_TCP_ADDR=172.17.0.1

# you can customize the environment
# variables through a custom docker link alias
dokku elasticsearch:alias lolipop ELASTICSEARCH_DATABASE

# you can also unlink a elasticsearch service
# NOTE: this will restart your app
dokku elasticsearch:unlink lolipop playground

# you can tail logs for a particular service
dokku elasticsearch:logs lolipop
dokku elasticsearch:logs lolipop -t # to tail

# finally, you can destroy the container
dokku elasticsearch:destroy playground
```

## todo

- implement elasticsearch:clone
- implement elasticsearch:expose
- implement elasticsearch:import
