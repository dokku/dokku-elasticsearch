# dokku elasticsearch [![Build Status](https://img.shields.io/github/actions/workflow/status/dokku/dokku-elasticsearch/ci.yml?branch=master&style=flat-square "Build Status")](https://github.com/dokku/dokku-elasticsearch/actions/workflows/ci.yml?query=branch%3Amaster) [![IRC Network](https://img.shields.io/badge/irc-libera-blue.svg?style=flat-square "IRC Libera")](https://webchat.libera.chat/?channels=dokku)

Official elasticsearch plugin for dokku. Currently defaults to installing [elasticsearch 9.5.3](https://hub.docker.com/_/elasticsearch/).

## Requirements

- dokku 0.35.x+
- docker 1.8.x

## Installation

```shell
# on 0.35.x+
sudo dokku plugin:install https://github.com/dokku/dokku-elasticsearch.git --name elasticsearch
```

## Commands

```
elasticsearch:app-links [<app>]                    # list all Elasticsearch service links for a given app
elasticsearch:create <service> [--create-flags...] # create a Elasticsearch service
elasticsearch:destroy <service> [-f|--force]       # delete the Elasticsearch service/data/container if there are no links left
elasticsearch:enter <service>                      # enter or run a command in a running Elasticsearch service container
elasticsearch:exists <service>                     # check if the Elasticsearch service exists
elasticsearch:expose <service> <ports...>          # expose a Elasticsearch service on custom host:port if provided (random port on the 0.0.0.0 interface if otherwise unspecified)
elasticsearch:info <service> [--info-flags...]     # print the service information
elasticsearch:link <service> [<app>] [--link-flags...] # link the Elasticsearch service to the app
elasticsearch:linked <service> [<app>]             # check if the Elasticsearch service is linked to an app
elasticsearch:links <service>                      # list all apps linked to the Elasticsearch service
elasticsearch:list                                 # list all Elasticsearch services
elasticsearch:logs <service> [-t|--tail [<tail-num>]] # print the most recent log(s) for this service
elasticsearch:pause <service>                      # pause a running Elasticsearch service
elasticsearch:promote <service> [<app>]            # promote service <service> as ELASTICSEARCH_URL in <app>
elasticsearch:restart <service>                    # graceful shutdown and restart of the Elasticsearch service container
elasticsearch:set <service> <key> <value>          # set or clear a property for a service
elasticsearch:start <service>                      # start a previously stopped Elasticsearch service
elasticsearch:stop <service>                       # stop a running Elasticsearch service
elasticsearch:unexpose <service>                   # unexpose a previously exposed Elasticsearch service
elasticsearch:unlink <service> [<app>] [-n|--no-restart] # unlink the Elasticsearch service from the app
elasticsearch:upgrade <service> [--upgrade-flags...] # upgrade service <service> to the specified versions
```

## Usage

Help for any commands can be displayed by specifying the command as an argument to elasticsearch:help. Plugin help output in conjunction with any files in the `docs/` folder is used to generate the plugin documentation. Please consult the `elasticsearch:help` command for any undocumented commands.

### Basic Usage

### create a Elasticsearch service

```shell
# usage
dokku elasticsearch:create <service> [--create-flags...]
```

flags:

- `-c|--config-options <string>`: extra arguments to pass to the container create command
- `-C|--custom-env <string>`: semi-colon delimited environment variables to start the service with
- `-i|--image <string>`: the image name to start the service with
- `-I|--image-version <string>`: the image version to start the service with
- `-N|--initial-network <string>`: the initial network to attach the service to
- `-m|--memory <int>`: container memory limit in megabytes (default: unlimited)
- `-p|--password <string>`: override the user-level service password
- `-P|--post-create-network <strings>`: a comma-separated list of networks to attach the service container to after service creation
- `-S|--post-start-network <strings>`: a comma-separated list of networks to attach the service container to after service start
- `-r|--root-password <string>`: override the root-level service password
- `-s|--shm-size <string>`: override shared memory size for the service docker container

Create a elasticsearch service named lollipop:

```shell
dokku elasticsearch:create lollipop
```

You can also specify the image and image version to use for the service. It *must* be compatible with the elasticsearch image.

```shell
export ELASTICSEARCH_IMAGE="elasticsearch"
export ELASTICSEARCH_IMAGE_VERSION="9.5.3"
dokku elasticsearch:create lollipop
```

You can also specify custom environment variables to start the elasticsearch service in semicolon-separated form.

```shell
export ELASTICSEARCH_CUSTOM_ENV="USER=alpha;HOST=beta"
dokku elasticsearch:create lollipop
```

### delete the Elasticsearch service/data/container if there are no links left

```shell
# usage
dokku elasticsearch:destroy <service> [-f|--force]
```

flags:

- `-f|--force`: force the destruction of the service

Destroy the service, it's data, and the running container:

```shell
dokku elasticsearch:destroy lollipop
```

### print the service information

```shell
# usage
dokku elasticsearch:info <service> [--info-flags...]
```

flags:

- `--config-dir`: show the service configuration directory
- `--data-dir`: show the service data directory
- `--dsn`: show the service DSN
- `--exposed-ports`: show service exposed ports
- `--id`: show the service container id
- `--initial-network`: show the initial network being connected to
- `--internal-ip`: show the service internal ip
- `--links`: show the service app links
- `--post-create-network`: show the networks to attach to after service container creation
- `--post-start-network`: show the networks to attach to after service container start
- `--service-root`: show the service root directory
- `--status`: show the service running status
- `--version`: show the service image version

Get connection information as follows:

```shell
dokku elasticsearch:info lollipop
```

You can also retrieve a specific piece of service info via flags:

```shell
dokku elasticsearch:info lollipop --config-dir
dokku elasticsearch:info lollipop --data-dir
dokku elasticsearch:info lollipop --dsn
dokku elasticsearch:info lollipop --exposed-ports
dokku elasticsearch:info lollipop --id
dokku elasticsearch:info lollipop --internal-ip
dokku elasticsearch:info lollipop --initial-network
dokku elasticsearch:info lollipop --links
dokku elasticsearch:info lollipop --post-create-network
dokku elasticsearch:info lollipop --post-start-network
dokku elasticsearch:info lollipop --service-root
dokku elasticsearch:info lollipop --status
dokku elasticsearch:info lollipop --version
```

### list all Elasticsearch services

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
dokku elasticsearch:logs <service> [-t|--tail [<tail-num>]]
```

flags:

- `-t|--tail <int>`: tail the logs, optionally showing this many lines

You can tail logs for a particular service:

```shell
dokku elasticsearch:logs lollipop
```

By default, logs will not be tailed, but you can do this with the --tail flag:

```shell
dokku elasticsearch:logs lollipop --tail
```

By default the last 100 lines are shown, but a different count can be specified:

```shell
dokku elasticsearch:logs lollipop --tail=5
```

### link the Elasticsearch service to the app

```shell
# usage
dokku elasticsearch:link <service> [<app>] [--link-flags...]
```

flags:

- `-a|--alias <string>`: an alternative alias to use for the config url exported to the app
- `-n|--no-restart`: whether to skip restarting the app
- `-q|--querystring <string>`: ampersand delimited querystring arguments to append to the service url

A elasticsearch service can be linked to a container. This will use native docker links via the docker-options plugin. Here we link it to our `playground` app.

> NOTE: this will restart your app

```shell
dokku elasticsearch:link lollipop playground
```

The following environment variables will be set automatically by docker (not on the app itself, so they won’t be listed when calling dokku config):

```
DOKKU_ELASTICSEARCH_LOLLIPOP_NAME=/lollipop/DATABASE
DOKKU_ELASTICSEARCH_LOLLIPOP_PORT=tcp://172.17.0.1:9200
DOKKU_ELASTICSEARCH_LOLLIPOP_PORT_9200_TCP=tcp://172.17.0.1:9200
DOKKU_ELASTICSEARCH_LOLLIPOP_PORT_9200_TCP_PROTO=tcp
DOKKU_ELASTICSEARCH_LOLLIPOP_PORT_9200_TCP_PORT=9200
DOKKU_ELASTICSEARCH_LOLLIPOP_PORT_9200_TCP_ADDR=172.17.0.1
```

The following will be set on the linked application by default:

```
ELASTICSEARCH_URL=http://:SOME_PASSWORD@dokku-elasticsearch-lollipop:9200
```

The host exposed here only works internally in docker containers. If you want your container to be reachable from outside, you should use the `expose` subcommand. Another service can be linked to your app:

```shell
dokku elasticsearch:link other_service playground
```

It is possible to change the protocol for `ELASTICSEARCH_URL` by setting the environment variable `ELASTICSEARCH_DATABASE_SCHEME` on the app. Doing so will after linking will cause the plugin to think the service is not linked, and we advise you to unlink before proceeding.

```shell
dokku config:set playground ELASTICSEARCH_DATABASE_SCHEME=http2
dokku elasticsearch:link lollipop playground
```

This will cause `ELASTICSEARCH_URL` to be set as:

```
http2://:SOME_PASSWORD@dokku-elasticsearch-lollipop:9200
```

### unlink the Elasticsearch service from the app

```shell
# usage
dokku elasticsearch:unlink <service> [<app>] [-n|--no-restart]
```

flags:

- `-n|--no-restart`: whether to skip restarting the app

You can unlink a elasticsearch service:

> NOTE: this will restart your app and unset related environment variables

```shell
dokku elasticsearch:unlink lollipop playground
```

### set or clear a property for a service

```shell
# usage
dokku elasticsearch:set <service> <key> <value>
```

Set the network to attach after the service container is started:

```shell
dokku elasticsearch:set lollipop post-create-network custom-network
```

Set multiple networks:

```shell
dokku elasticsearch:set lollipop post-create-network custom-network,other-network
```

Unset the post-create-network value:

```shell
dokku elasticsearch:set lollipop post-create-network
```

Set the keyserver a public key for backup encryption is fetched from:

```shell
dokku elasticsearch:set lollipop backup-keyserver hkp://keys.example.com
```

### Service Lifecycle

The lifecycle of each service can be managed through the following commands:

### enter or run a command in a running Elasticsearch service container

```shell
# usage
dokku elasticsearch:enter <service>
```

A bash prompt can be opened against a running service. Filesystem changes will not be saved to disk.

> NOTE: disconnecting from ssh while running this command may leave zombie processes due to moby/moby#9098

```shell
dokku elasticsearch:enter lollipop
```

You may also run a command directly against the service. Filesystem changes will not be saved to disk.

```shell
dokku elasticsearch:enter lollipop touch /tmp/test
```

### expose a Elasticsearch service on custom host:port if provided (random port on the 0.0.0.0 interface if otherwise unspecified)

```shell
# usage
dokku elasticsearch:expose <service> <ports...>
```

Expose the service on the service's normal ports, allowing access to it from the public interface (`0.0.0.0`):

```shell
dokku elasticsearch:expose lollipop 9200 9300
```

Expose the service on the service's normal ports, with the first on a specified ip address (127.0.0.1):

```shell
dokku elasticsearch:expose lollipop 127.0.0.1:9200 9300
```

### unexpose a previously exposed Elasticsearch service

```shell
# usage
dokku elasticsearch:unexpose <service>
```

Unexpose the service, removing access to it from the public interface (`0.0.0.0`):

```shell
dokku elasticsearch:unexpose lollipop
```

### promote service <service> as ELASTICSEARCH_URL in <app>

```shell
# usage
dokku elasticsearch:promote <service> [<app>]
```

If you have a elasticsearch service linked to an app and try to link another elasticsearch service another link environment variable will be generated automatically:

```
DOKKU_ELASTICSEARCH_BLUE_URL=http://:ANOTHER_PASSWORD@dokku-elasticsearch-other-service:9200/other_service
```

You can promote the new service to be the primary one:

> NOTE: this will restart your app

```shell
dokku elasticsearch:promote other_service playground
```

This will replace `ELASTICSEARCH_URL` with the url from other_service and generate another environment variable to hold the previous value if necessary. You could end up with the following for example:

```
ELASTICSEARCH_URL=http://:ANOTHER_PASSWORD@dokku-elasticsearch-other-service:9200/other_service
DOKKU_ELASTICSEARCH_BLUE_URL=http://:ANOTHER_PASSWORD@dokku-elasticsearch-other-service:9200/other_service
DOKKU_ELASTICSEARCH_SILVER_URL=http://:SOME_PASSWORD@dokku-elasticsearch-lollipop:9200/lollipop
```

### start a previously stopped Elasticsearch service

```shell
# usage
dokku elasticsearch:start <service>
```

Start the service:

```shell
dokku elasticsearch:start lollipop
```

### stop a running Elasticsearch service

```shell
# usage
dokku elasticsearch:stop <service>
```

Stop the service and removes the running container:

```shell
dokku elasticsearch:stop lollipop
```

### pause a running Elasticsearch service

```shell
# usage
dokku elasticsearch:pause <service>
```

Pause the running container for the service:

```shell
dokku elasticsearch:pause lollipop
```

### graceful shutdown and restart of the Elasticsearch service container

```shell
# usage
dokku elasticsearch:restart <service>
```

Restart the service:

```shell
dokku elasticsearch:restart lollipop
```

### upgrade service <service> to the specified versions

```shell
# usage
dokku elasticsearch:upgrade <service> [--upgrade-flags...]
```

flags:

- `-c|--config-options <string>`: extra arguments to pass to the container create command
- `-C|--custom-env <string>`: semi-colon delimited environment variables to start the service with
- `-i|--image <string>`: the image to upgrade the service to
- `-I|--image-version <string>`: the image version to upgrade the service to
- `-N|--initial-network <string>`: the initial network to attach the service to
- `-P|--post-create-network <strings>`: a comma-separated list of networks to attach the service container to after service creation
- `-S|--post-start-network <strings>`: a comma-separated list of networks to attach the service container to after service start
- `-R|--restart-apps`: whether to stop and start the linked apps around the upgrade
- `-s|--shm-size <string>`: override shared memory size for the service docker container

You can upgrade an existing service to a new image or image-version:

```shell
dokku elasticsearch:upgrade lollipop
```

### Service Automation

Service scripting can be executed using the following commands:

### list all Elasticsearch service links for a given app

```shell
# usage
dokku elasticsearch:app-links [<app>]
```

List all elasticsearch services that are linked to the `playground` app.

```shell
dokku elasticsearch:app-links playground
```

### check if the Elasticsearch service exists

```shell
# usage
dokku elasticsearch:exists <service>
```

Here we check if the lollipop elasticsearch service exists.

```shell
dokku elasticsearch:exists lollipop
```

### check if the Elasticsearch service is linked to an app

```shell
# usage
dokku elasticsearch:linked <service> [<app>]
```

Here we check if the lollipop elasticsearch service is linked to the `playground` app.

```shell
dokku elasticsearch:linked lollipop playground
```

### list all apps linked to the Elasticsearch service

```shell
# usage
dokku elasticsearch:links <service>
```

List all apps linked to the `lollipop` elasticsearch service.

```shell
dokku elasticsearch:links lollipop
```

### Disabling `docker image pull` calls

If you wish to disable the `docker image pull` calls that the plugin triggers, you may set the `ELASTICSEARCH_DISABLE_PULL` environment variable to `true`. Once disabled, you will need to pull the service image you wish to deploy as shown in the `stderr` output.

Please ensure the proper images are in place when `docker image pull` is disabled.
