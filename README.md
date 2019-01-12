# dokku elasticsearch [![Build Status](https://img.shields.io/travis/dokku/dokku-elasticsearch.svg?branch=master "Build Status")](https://travis-ci.org/dokku/dokku-elasticsearch) [![IRC Network](https://img.shields.io/badge/irc-freenode-blue.svg "IRC Freenode")](https://webchat.freenode.net/?channels=dokku)

Official elasticsearch plugin for dokku. Currently defaults to installing [elasticsearch 2.3.5](https://hub.docker.com/_/elasticsearch/).
It's possible to install Elasticsearch 5.x, but it does require some manual setup. 

## requirements

- dokku 0.4.x+
- docker 1.8.x

## installation

```shell
# on 0.4.x+
sudo dokku plugin:install https://github.com/dokku/dokku-elasticsearch.git elasticsearch
```

If you want to run elasticsearch 5.x, there's a requirement to increase the `vm.max_map_count`
value in `/etc/sysctl.conf`.

```shell
# add or update: vm.max_map_count = 262144
vi /etc/sysctl.conf

# load the change variables from /etc/sysctl.conf
sysctl -p 
```

## commands

```
elasticsearch:app-links <app>          List all elasticsearch service links for a given app
elasticsearch:backup <name> <bucket> (--use-iam) NOT IMPLEMENTED
elasticsearch:backup-auth <name> <aws_access_key_id> <aws_secret_access_key> (<aws_default_region>) (<aws_signature_version>) (<endpoint_url>) NOT IMPLEMENTED
elasticsearch:backup-deauth <name>     NOT IMPLEMENTED
elasticsearch:backup-schedule <name> <schedule> <bucket> NOT IMPLEMENTED
elasticsearch:backup-schedule-cat <name> NOT IMPLEMENTED
elasticsearch:backup-set-encryption <name> <passphrase> NOT IMPLEMENTED
elasticsearch:backup-unschedule <name> NOT IMPLEMENTED
elasticsearch:backup-unset-encryption <name> NOT IMPLEMENTED
elasticsearch:clone <name> <new-name>  NOT IMPLEMENTED
elasticsearch:connect <name>           NOT IMPLEMENTED
elasticsearch:create <name>            Create a elasticsearch service with environment variables
elasticsearch:destroy <name>           Delete the service, delete the data and stop its container if there are no links left
elasticsearch:enter <name> [command]   Enter or run a command in a running elasticsearch service container
elasticsearch:exists <service>         Check if the elasticsearch service exists
elasticsearch:export <name> > <file>   NOT IMPLEMENTED
elasticsearch:expose <name> [port]     Expose a elasticsearch service on custom port if provided (random port otherwise)
elasticsearch:import <name> <file>     NOT IMPLEMENTED
elasticsearch:info <name>              Print the connection information
elasticsearch:link <name> <app>        Link the elasticsearch service to the app
elasticsearch:linked <name> <app>      Check if the elasticsearch service is linked to an app
elasticsearch:list                     List all elasticsearch services
elasticsearch:logs <name> [-t]         Print the most recent log(s) for this service
elasticsearch:promote <name> <app>     Promote service <name> as ELASTICSEARCH_URL in <app>
elasticsearch:restart <name>           Graceful shutdown and restart of the elasticsearch service container
elasticsearch:start <name>             Start a previously stopped elasticsearch service
elasticsearch:stop <name>              Stop a running elasticsearch service
elasticsearch:unexpose <name>          Unexpose a previously exposed elasticsearch service
elasticsearch:unlink <name> <app>      Unlink the elasticsearch service from the app
elasticsearch:upgrade <name>           Upgrade service <service> to the specified version
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

# if you want to use elasticsearch 5.x, you
# will need to increase `vm.max_map_count` in 
# /etc/sysctl.conf. See #install
export ELASTICSEARCH_IMAGE="elasticsearch"
export ELASTICSEARCH_IMAGE_VERSION="5.6.12"
dokku elasticsearch:create lolipop

# you can also specify custom environment
# variables to start the elasticsearch service
# in semi-colon separated form
export ELASTICSEARCH_CUSTOM_ENV="USER=alpha;HOST=beta"
dokku elasticsearch:create lolipop

# get connection information as follows
dokku elasticsearch:info lolipop

# you can also retrieve a specific piece of service info via flags
dokku elasticsearch:info lolipop --config-dir
dokku elasticsearch:info lolipop --data-dir
dokku elasticsearch:info lolipop --dsn
dokku elasticsearch:info lolipop --exposed-ports
dokku elasticsearch:info lolipop --id
dokku elasticsearch:info lolipop --internal-ip
dokku elasticsearch:info lolipop --links
dokku elasticsearch:info lolipop --service-root
dokku elasticsearch:info lolipop --status
dokku elasticsearch:info lolipop --version

# a bash prompt can be opened against a running service
# filesystem changes will not be saved to disk
dokku elasticsearch:enter lolipop

# you may also run a command directly against the service
# filesystem changes will not be saved to disk
dokku elasticsearch:enter lolipop ls -lah /

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

## Changing database adapter

It's possible to change the protocol for ELASTICSEARCH_URL by setting
the environment variable ELASTICSEARCH_DATABASE_SCHEME on the app:

```
dokku config:set playground ELASTICSEARCH_DATABASE_SCHEME=elasticsearch2
dokku elasticsearch:link lolipop playground
```

Will cause ELASTICSEARCH_URL to be set as
elasticsearch2://dokku-elasticsearch-lolipop:9200

CAUTION: Changing ELASTICSEARCH_DATABASE_SCHEME after linking will cause dokku to
believe the elasticsearch is not linked when attempting to use `dokku elasticsearch:unlink`
or `dokku elasticsearch:promote`.
You should be able to fix this by

- Changing ELASTICSEARCH_URL manually to the new value.

OR

- Set ELASTICSEARCH_DATABASE_SCHEME back to its original setting
- Unlink the service
- Change ELASTICSEARCH_DATABASE_SCHEME to the desired setting
- Relink the service

## Disabling `docker pull` calls

If you wish to disable the `docker pull` calls that the plugin triggers, you may set the `ELASTICSEARCH_DISABLE_PULL` environment variable to `true`. Once disabled, you will need to pull the service image you wish to deploy as shown in the `stderr` output.

Please ensure the proper images are in place when `docker pull` is disabled.

## JVM Settings

In order to get out-of-the-box working deployments of elasticsearch the maximum 
memory allocation of the JVM is limited to 512m. You can change this in 
`/var/lib/dokku/services/elasticsearch/<service>/config/jvm.options`. 

The following example changes the initial (`-Xms`) and maximum (`-Xmx`) memory
allocations for the JVM from 512m to 2g. 

```
# -Xms512m
# -Xmx512m
-Xms2g
-Xmx2g
```

After making this change, make sure to restart your container with 
`dokku elasticsearch:restart`. 
