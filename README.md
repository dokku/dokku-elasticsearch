# dokku elasticsearch [![Build Status](https://img.shields.io/circleci/project/github/dokku/dokku-elasticsearch.svg?branch=master&style=flat-square "Build Status")](https://circleci.com/gh/dokku/dokku-elasticsearch/tree/master) [![IRC Network](https://img.shields.io/badge/irc-freenode-blue.svg?style=flat-square "IRC Freenode")](https://webchat.freenode.net/?channels=dokku)

Official elasticsearch plugin for dokku. Currently defaults to installing [elasticsearch 6.8.5](https://hub.docker.com/_/elasticsearch/).

## Requirements

- dokku 0.12.x+
- docker 1.8.x

## Installation

```shell
# on 0.12.x+
sudo dokku plugin:install https://github.com/dokku/dokku-elasticsearch.git elasticsearch
```

## Commands

```
elasticsearch:app-links <app>                      # list all elasticsearch service links for a given app
elasticsearch:create <service> [--create-flags...] # create a elasticsearch service
elasticsearch:destroy <service> [-f|--force]       # delete the elasticsearch service/data/container if there are no links left
elasticsearch:enter <service>                      # enter or run a command in a running elasticsearch service container
elasticsearch:exists <service>                     # check if the elasticsearch service exists
elasticsearch:expose <service> <ports...>          # expose a elasticsearch service on custom port if provided (random port otherwise)
elasticsearch:info <service> [--single-info-flag]  # print the service information
elasticsearch:link <service> <app> [--link-flags...] # link the elasticsearch service to the app
elasticsearch:linked <service> <app>               # check if the elasticsearch service is linked to an app
elasticsearch:links <service>                      # list all apps linked to the elasticsearch service
elasticsearch:list                                 # list all elasticsearch services
elasticsearch:logs <service> [-t|--tail]           # print the most recent log(s) for this service
elasticsearch:promote <service> <app>              # promote service <service> as ELASTICSEARCH_URL in <app>
elasticsearch:restart <service>                    # graceful shutdown and restart of the elasticsearch service container
elasticsearch:start <service>                      # start a previously stopped elasticsearch service
elasticsearch:stop <service>                       # stop a running elasticsearch service
elasticsearch:unexpose <service>                   # unexpose a previously exposed elasticsearch service
elasticsearch:unlink <service> <app>               # unlink the elasticsearch service from the app
elasticsearch:upgrade <service> [--upgrade-flags...] # upgrade service <service> to the specified versions
```

## Usage

Help for any commands can be displayed by specifying the command as an argument to elasticsearch:help. Please consult the `elasticsearch:help` command for any undocumented commands.

### Basic Usage

### create a elasticsearch service

```shell
# usage
dokku elasticsearch:create <service> [--create-flags...]
```

flags:

- `-C|--custom-env "USER=alpha;HOST=beta"`: semi-colon delimited environment variables to start the service with
- `-i|--image IMAGE`: the image name to start the service with
- `-I|--image-version IMAGE_VERSION`: the image version to start the service with
- `-p|--password PASSWORD`: override the user-level service password
- `-r|--root-password PASSWORD`: override the root-level service password

Create a elasticsearch service named lolipop:

```shell
dokku elasticsearch:create lolipop
```

You can also specify the image and image version to use for the service. It *must* be compatible with the elasticsearch image. 

```shell
export ELASTICSEARCH_IMAGE="elasticsearch"
export ELASTICSEARCH_IMAGE_VERSION="${PLUGIN_IMAGE_VERSION}"
dokku elasticsearch:create lolipop
```

You can also specify custom environment variables to start the elasticsearch service in semi-colon separated form. 

```shell
export ELASTICSEARCH_CUSTOM_ENV="USER=alpha;HOST=beta"
dokku elasticsearch:create lolipop
```

### print the service information

```shell
# usage
dokku elasticsearch:info <service> [--single-info-flag]
```

flags:

- `--config-dir`: show the service configuration directory
- `--data-dir`: show the service data directory
- `--dsn`: show the service DSN
- `--exposed-ports`: show service exposed ports
- `--id`: show the service container id
- `--internal-ip`: show the service internal ip
- `--links`: show the service app links
- `--service-root`: show the service root directory
- `--status`: show the service running status
- `--version`: show the service image version

Get connection information as follows:

```shell
dokku elasticsearch:info lolipop
```

You can also retrieve a specific piece of service info via flags:

```shell
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
```

### list all elasticsearch services

```shell
# usage
dokku elasticsearch:list 
```

List all services:

```shell
dokku elasticsearch:list
```

### print the most recent log(s) for this service

```shell
# usage
dokku elasticsearch:logs <service> [-t|--tail]
```

flags:

- `-t|--tail`: do not stop when end of the logs are reached and wait for additional output

You can tail logs for a particular service:

```shell
dokku elasticsearch:logs lolipop
```

By default, logs will not be tailed, but you can do this with the --tail flag:

```shell
dokku elasticsearch:logs lolipop --tail
```

### link the elasticsearch service to the app

```shell
# usage
dokku elasticsearch:link <service> <app> [--link-flags...]
```

flags:

- `-a|--alias "BLUE_DATABASE"`: an alternative alias to use for linking to an app via environment variable
- `-q|--querystring "pool=5"`: ampersand delimited querystring arguments to append to the service link

A elasticsearch service can be linked to a container. This will use native docker links via the docker-options plugin. Here we link it to our 'playground' app. 

> NOTE: this will restart your app

```shell
dokku elasticsearch:link lolipop playground
```

The following environment variables will be set automatically by docker (not on the app itself, so they won’t be listed when calling dokku config):

```
DOKKU_ELASTICSEARCH_LOLIPOP_NAME=/lolipop/DATABASE
DOKKU_ELASTICSEARCH_LOLIPOP_PORT=tcp://172.17.0.1:9200
DOKKU_ELASTICSEARCH_LOLIPOP_PORT_9200_TCP=tcp://172.17.0.1:9200
DOKKU_ELASTICSEARCH_LOLIPOP_PORT_9200_TCP_PROTO=tcp
DOKKU_ELASTICSEARCH_LOLIPOP_PORT_9200_TCP_PORT=9200
DOKKU_ELASTICSEARCH_LOLIPOP_PORT_9200_TCP_ADDR=172.17.0.1
```

The following will be set on the linked application by default:

```
ELASTICSEARCH_URL=http://lolipop:SOME_PASSWORD@dokku-elasticsearch-lolipop:9200/lolipop
```

The host exposed here only works internally in docker containers. If you want your container to be reachable from outside, you should use the 'expose' subcommand. Another service can be linked to your app:

```shell
dokku elasticsearch:link other_service playground
```

It is possible to change the protocol for `ELASTICSEARCH_URL` by setting the environment variable `ELASTICSEARCH_DATABASE_SCHEME` on the app. Doing so will after linking will cause the plugin to think the service is not linked, and we advise you to unlink before proceeding. 

```shell
dokku config:set playground ELASTICSEARCH_DATABASE_SCHEME=http2
dokku elasticsearch:link lolipop playground
```

This will cause `ELASTICSEARCH_URL` to be set as:

```
http2://lolipop:SOME_PASSWORD@dokku-elasticsearch-lolipop:9200/lolipop
```

### unlink the elasticsearch service from the app

```shell
# usage
dokku elasticsearch:unlink <service> <app>
```

You can unlink a elasticsearch service:

> NOTE: this will restart your app and unset related environment variables

```shell
dokku elasticsearch:unlink lolipop playground
```

### Service Lifecycle

The lifecycle of each service can be managed through the following commands:

### enter or run a command in a running elasticsearch service container

```shell
# usage
dokku elasticsearch:enter <service>
```

A bash prompt can be opened against a running service. Filesystem changes will not be saved to disk. 

```shell
dokku elasticsearch:enter lolipop
```

You may also run a command directly against the service. Filesystem changes will not be saved to disk. 

```shell
dokku elasticsearch:enter lolipop touch /tmp/test
```

### expose a elasticsearch service on custom port if provided (random port otherwise)

```shell
# usage
dokku elasticsearch:expose <service> <ports...>
```

Expose the service on the service's normal ports, allowing access to it from the public interface (`0.0.0.0`):

```shell
dokku elasticsearch:expose lolipop 9200 9300
```

### unexpose a previously exposed elasticsearch service

```shell
# usage
dokku elasticsearch:unexpose <service>
```

Unexpose the service, removing access to it from the public interface (`0.0.0.0`):

```shell
dokku elasticsearch:unexpose lolipop
```

### promote service <service> as ELASTICSEARCH_URL in <app>

```shell
# usage
dokku elasticsearch:promote <service> <app>
```

If you have a elasticsearch service linked to an app and try to link another elasticsearch service another link environment variable will be generated automatically:

```
DOKKU_ELASTICSEARCH_BLUE_URL=http://other_service:ANOTHER_PASSWORD@dokku-elasticsearch-other-service:9200/other_service
```

You can promote the new service to be the primary one:

> NOTE: this will restart your app

```shell
dokku elasticsearch:promote other_service playground
```

This will replace `ELASTICSEARCH_URL` with the url from other_service and generate another environment variable to hold the previous value if necessary. You could end up with the following for example:

```
ELASTICSEARCH_URL=http://other_service:ANOTHER_PASSWORD@dokku-elasticsearch-other-service:9200/other_service
DOKKU_ELASTICSEARCH_BLUE_URL=http://other_service:ANOTHER_PASSWORD@dokku-elasticsearch-other-service:9200/other_service
DOKKU_ELASTICSEARCH_SILVER_URL=http://lolipop:SOME_PASSWORD@dokku-elasticsearch-lolipop:9200/lolipop
```

### start a previously stopped elasticsearch service

```shell
# usage
dokku elasticsearch:start <service>
```

Start the service:

```shell
dokku elasticsearch:start lolipop
```

### stop a running elasticsearch service

```shell
# usage
dokku elasticsearch:stop <service>
```

Stop the service and the running container:

```shell
dokku elasticsearch:stop lolipop
```

### graceful shutdown and restart of the elasticsearch service container

```shell
# usage
dokku elasticsearch:restart <service>
```

Restart the service:

```shell
dokku elasticsearch:restart lolipop
```

### upgrade service <service> to the specified versions

```shell
# usage
dokku elasticsearch:upgrade <service> [--upgrade-flags...]
```

flags:

- `-C|--custom-env "USER=alpha;HOST=beta"`: semi-colon delimited environment variables to start the service with
- `-i|--image IMAGE`: the image name to start the service with
- `-I|--image-version IMAGE_VERSION`: the image version to start the service with
- `-R|--restart-apps "true"`: whether to force an app restart

You can upgrade an existing service to a new image or image-version:

```shell
dokku elasticsearch:upgrade lolipop
```

### Service Automation

Service scripting can be executed using the following commands:

### list all elasticsearch service links for a given app

```shell
# usage
dokku elasticsearch:app-links <app>
```

List all elasticsearch services that are linked to the 'playground' app. 

```shell
dokku elasticsearch:app-links playground
```

### check if the elasticsearch service exists

```shell
# usage
dokku elasticsearch:exists <service>
```

Here we check if the lolipop elasticsearch service exists. 

```shell
dokku elasticsearch:exists lolipop
```

### check if the elasticsearch service is linked to an app

```shell
# usage
dokku elasticsearch:linked <service> <app>
```

Here we check if the lolipop elasticsearch service is linked to the 'playground' app. 

```shell
dokku elasticsearch:linked lolipop playground
```

### list all apps linked to the elasticsearch service

```shell
# usage
dokku elasticsearch:links <service>
```

List all apps linked to the 'lolipop' elasticsearch service. 

```shell
dokku elasticsearch:links lolipop
```

### Disabling `docker pull` calls

If you wish to disable the `docker pull` calls that the plugin triggers, you may set the `ELASTICSEARCH_DISABLE_PULL` environment variable to `true`. Once disabled, you will need to pull the service image you wish to deploy as shown in the `stderr` output.

Please ensure the proper images are in place when `docker pull` is disabled.