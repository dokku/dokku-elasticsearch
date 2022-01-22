# dokku elasticsearch [![Build Status](https://img.shields.io/github/workflow/status/dokku/dokku-elasticsearch/CI/master?style=flat-square "Build Status")](https://github.com/dokku/dokku-elasticsearch/actions/workflows/ci.yml?query=branch%3Amaster) [![IRC Network](https://img.shields.io/badge/irc-libera-blue.svg?style=flat-square "IRC Libera")](https://webchat.libera.chat/?channels=dokku)

Official elasticsearch plugin for dokku. Currently defaults to installing [elasticsearch 7.16.3](https://hub.docker.com/_/elasticsearch/).

## Requirements

- dokku 0.19.x+
- docker 1.8.x

## Installation

```shell
# on 0.19.x+
sudo dokku plugin:install https://github.com/dokku/dokku-elasticsearch.git elasticsearch
```

## Commands

```
elasticsearch:app-links <app>                      # list all elasticsearch service links for a given app
elasticsearch:create <service> [--create-flags...] # create a elasticsearch service
elasticsearch:destroy <service> [-f|--force]       # delete the elasticsearch service/data/container if there are no links left
elasticsearch:enter <service>                      # enter or run a command in a running elasticsearch service container
elasticsearch:exists <service>                     # check if the elasticsearch service exists
elasticsearch:expose <service> <ports...>          # expose a elasticsearch service on custom host:port if provided (random port on the 0.0.0.0 interface if otherwise unspecified)
elasticsearch:info <service> [--single-info-flag]  # print the service information
elasticsearch:link <service> <app> [--link-flags...] # link the elasticsearch service to the app
elasticsearch:linked <service> <app>               # check if the elasticsearch service is linked to an app
elasticsearch:links <service>                      # list all apps linked to the elasticsearch service
elasticsearch:list                                 # list all elasticsearch services
elasticsearch:logs <service> [-t|--tail] <tail-num-optional> # print the most recent log(s) for this service
elasticsearch:promote <service> <app>              # promote service <service> as ELASTICSEARCH_URL in <app>
elasticsearch:restart <service>                    # graceful shutdown and restart of the elasticsearch service container
elasticsearch:start <service>                      # start a previously stopped elasticsearch service
elasticsearch:stop <service>                       # stop a running elasticsearch service
elasticsearch:unexpose <service>                   # unexpose a previously exposed elasticsearch service
elasticsearch:unlink <service> <app>               # unlink the elasticsearch service from the app
elasticsearch:upgrade <service> [--upgrade-flags...] # upgrade service <service> to the specified versions
```

## Usage

Help for any commands can be displayed by specifying the command as an argument to elasticsearch:help. Plugin help output in conjunction with any files in the `docs/` folder is used to generate the plugin documentation. Please consult the `elasticsearch:help` command for any undocumented commands.

### Basic Usage

### create a elasticsearch service

```shell
# usage
dokku elasticsearch:create <service> [--create-flags...]
```

flags:

- `-c|--config-options "--args --go=here"`: extra arguments to pass to the container create command (default: `None`)
- `-C|--custom-env "USER=alpha;HOST=beta"`: semi-colon delimited environment variables to start the service with
- `-i|--image IMAGE`: the image name to start the service with
- `-I|--image-version IMAGE_VERSION`: the image version to start the service with
- `-m|--memory MEMORY`: container memory limit (default: unlimited)
- `-p|--password PASSWORD`: override the user-level service password
- `-r|--root-password PASSWORD`: override the root-level service password
- `-s|--shm-size SHM_SIZE`: override shared memory size for elasticsearch docker container

Create a elasticsearch service named lollipop:

```shell
dokku elasticsearch:create lollipop
```

You can also specify the image and image version to use for the service. It *must* be compatible with the elasticsearch image.

```shell
export ELASTICSEARCH_IMAGE="elasticsearch"
export ELASTICSEARCH_IMAGE_VERSION="${PLUGIN_IMAGE_VERSION}"
dokku elasticsearch:create lollipop
```

You can also specify custom environment variables to start the elasticsearch service in semi-colon separated form.

```shell
export ELASTICSEARCH_CUSTOM_ENV="USER=alpha;HOST=beta"
dokku elasticsearch:create lollipop
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
dokku elasticsearch:info lollipop --links
dokku elasticsearch:info lollipop --service-root
dokku elasticsearch:info lollipop --status
dokku elasticsearch:info lollipop --version
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
dokku elasticsearch:logs <service> [-t|--tail] <tail-num-optional>
```

flags:

- `-t|--tail [<tail-num>]`: do not stop when end of the logs are reached and wait for additional output

You can tail logs for a particular service:

```shell
dokku elasticsearch:logs lollipop
```

By default, logs will not be tailed, but you can do this with the --tail flag:

```shell
dokku elasticsearch:logs lollipop --tail
```

The default tail setting is to show all logs, but an initial count can also be specified:

```shell
dokku elasticsearch:logs lollipop --tail 5
```

### link the elasticsearch service to the app

```shell
# usage
dokku elasticsearch:link <service> <app> [--link-flags...]
```

flags:

- `-a|--alias "BLUE_DATABASE"`: an alternative alias to use for linking to an app via environment variable
- `-q|--querystring "pool=5"`: ampersand delimited querystring arguments to append to the service link

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
ELASTICSEARCH_URL=http://dokku-elasticsearch-lollipop:9200
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
http2://dokku-elasticsearch-lollipop:9200
```

### unlink the elasticsearch service from the app

```shell
# usage
dokku elasticsearch:unlink <service> <app>
```

You can unlink a elasticsearch service:

> NOTE: this will restart your app and unset related environment variables

```shell
dokku elasticsearch:unlink lollipop playground
```

### Service Lifecycle

The lifecycle of each service can be managed through the following commands:

### enter or run a command in a running elasticsearch service container

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

### expose a elasticsearch service on custom host:port if provided (random port on the 0.0.0.0 interface if otherwise unspecified)

```shell
# usage
dokku elasticsearch:expose <service> <ports...>
```

Expose the service on the service's normal ports, allowing access to it from the public interface (`0.0.0.0`):

```shell
dokku elasticsearch:expose lollipop 9200 9300
```

Expose the service on the service's normal ports, with the first on a specified ip adddress (127.0.0.1):

```shell
dokku elasticsearch:expose lollipop 127.0.0.1:9200 9300
```

### unexpose a previously exposed elasticsearch service

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
DOKKU_ELASTICSEARCH_SILVER_URL=http://lollipop:SOME_PASSWORD@dokku-elasticsearch-lollipop:9200/lollipop
```

### start a previously stopped elasticsearch service

```shell
# usage
dokku elasticsearch:start <service>
```

Start the service:

```shell
dokku elasticsearch:start lollipop
```

### stop a running elasticsearch service

```shell
# usage
dokku elasticsearch:stop <service>
```

Stop the service and the running container:

```shell
dokku elasticsearch:stop lollipop
```

### graceful shutdown and restart of the elasticsearch service container

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

- `-c|--config-options "--args --go=here"`: extra arguments to pass to the container create command (default: `None`)
- `-C|--custom-env "USER=alpha;HOST=beta"`: semi-colon delimited environment variables to start the service with
- `-i|--image IMAGE`: the image name to start the service with
- `-I|--image-version IMAGE_VERSION`: the image version to start the service with
- `-R|--restart-apps "true"`: whether to force an app restart
- `-s|--shm-size SHM_SIZE`: override shared memory size for elasticsearch docker container

You can upgrade an existing service to a new image or image-version:

```shell
dokku elasticsearch:upgrade lollipop
```

### Service Automation

Service scripting can be executed using the following commands:

### list all elasticsearch service links for a given app

```shell
# usage
dokku elasticsearch:app-links <app>
```

List all elasticsearch services that are linked to the `playground` app.

```shell
dokku elasticsearch:app-links playground
```

### check if the elasticsearch service exists

```shell
# usage
dokku elasticsearch:exists <service>
```

Here we check if the lollipop elasticsearch service exists.

```shell
dokku elasticsearch:exists lollipop
```

### check if the elasticsearch service is linked to an app

```shell
# usage
dokku elasticsearch:linked <service> <app>
```

Here we check if the lollipop elasticsearch service is linked to the `playground` app.

```shell
dokku elasticsearch:linked lollipop playground
```

### list all apps linked to the elasticsearch service

```shell
# usage
dokku elasticsearch:links <service>
```

List all apps linked to the `lollipop` elasticsearch service.

```shell
dokku elasticsearch:links lollipop
```

### Disabling `docker pull` calls

If you wish to disable the `docker pull` calls that the plugin triggers, you may set the `ELASTICSEARCH_DISABLE_PULL` environment variable to `true`. Once disabled, you will need to pull the service image you wish to deploy as shown in the `stderr` output.

Please ensure the proper images are in place when `docker pull` is disabled.
