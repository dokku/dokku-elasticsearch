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
elasticsearch:info [<service>] [--info-flags...]   # print the service information
elasticsearch:link <service> [<app>] [--link-flags...] # link the Elasticsearch service to the app
elasticsearch:linked <service> [<app>]             # check if the Elasticsearch service is linked to an app
elasticsearch:links <service>                      # list all apps linked to the Elasticsearch service
elasticsearch:list                                 # list all Elasticsearch services
elasticsearch:logs <service> [-t|--tail [<tail-num>]] # print the most recent log(s) for this service
elasticsearch:mount [--replace] <service> <source:container-dir[:options]>... # mount a host path or docker volume into the service container
elasticsearch:pause <service>                      # pause a running Elasticsearch service
elasticsearch:promote <service> [<app>]            # promote service <service> as ELASTICSEARCH_URL in <app>
elasticsearch:reexpose <service>                   # reexpose a Elasticsearch service, applying its expose settings without restarting it
elasticsearch:restart <service>                    # graceful shutdown and restart of the Elasticsearch service container
elasticsearch:set <service> <key> <value>          # set or clear a property for a service
elasticsearch:start <service>                      # start a previously stopped Elasticsearch service
elasticsearch:stop <service>                       # stop a running Elasticsearch service
elasticsearch:unexpose <service>                   # unexpose a previously exposed Elasticsearch service
elasticsearch:unlink <service> [<app>] [-n|--no-restart] # unlink the Elasticsearch service from the app
elasticsearch:unmount [--all] <service> [<source:container-dir>...] # remove one or all mounts from the service container
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

- `-c|--config-options <string>`: extra arguments for the process the service container runs, not docker flags; use mount for mounts
- `-C|--custom-env <string>`: semi-colon delimited environment variables to start the service with
- `-i|--image <string>`: the image name to start the service with
- `-I|--image-version <string>`: the image version to start the service with
- `-N|--initial-network <string>`: the initial network to attach the service to
- `--log-driver <string>`: the docker logging driver to run the service container with (default: the daemon's own)
- `--log-opt <strings>`: a comma-separated list of key=value docker log options for the service container
- `-m|--memory <int>`: container memory limit in megabytes (default: unlimited)
- `-p|--password <string>`: override the user-level service password, for datastores that have one
- `-P|--post-create-network <strings>`: a comma-separated list of networks to attach the service container to after service creation
- `-S|--post-start-network <strings>`: a comma-separated list of networks to attach the service container to after service start
- `--restart <string>`: the docker restart policy to run the service container with (default: always)
- `-r|--root-password <string>`: override the root-level service password, for datastores that have one
- `-s|--shm-size <string>`: override shared memory size for the service docker container
- `--volume <stringArray>`: a host path or docker volume to mount into the service container, as <source>:<container-dir>[:<options>], repeatable
- `--wait-timeout <string>`: seconds to wait for the service to become ready (default: the datastore's own)

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

An image other than elasticsearch has no version to fall back on, because the version this plugin pins belongs to elasticsearch, so name one alongside it.

```shell
dokku elasticsearch:create lollipop --image <image> --image-version <version>
```

You can also specify custom environment variables to start the elasticsearch service in semicolon-separated form.

```shell
export ELASTICSEARCH_CUSTOM_ENV="USER=alpha;HOST=beta"
dokku elasticsearch:create lollipop
```

The container log is bounded by whatever `dokku logs:set --global max-size` says, and by dokku's own default where it says nothing, which a service may override for itself.

```shell
dokku elasticsearch:create lollipop --log-opt max-size=20m,max-file=3
```

The container is restarted by docker whenever it stops, which a service may change for itself.

```shell
dokku elasticsearch:create lollipop --restart unless-stopped
```

The service is waited on until it answers, for as long as the datastore's own default, which a slow host may raise for every service with `ELASTICSEARCH_WAIT_TIMEOUT` or a service may raise for itself.

```shell
dokku elasticsearch:create lollipop --wait-timeout 120
```

The config options are handed to the process the container runs, not to docker, so a host path or docker volume is mounted with --volume, which may be repeated.

```shell
dokku elasticsearch:create lollipop --volume /var/lib/dokku/data/storage/lollipop:/opt/extra:ro
```

The service passwords are generated unless they are given. A datastore without a root password refuses --root-password rather than dropping it.

```shell
dokku elasticsearch:create lollipop --password <password> --root-password <root-password>
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

A service that is still linked to an app is not destroyed, and the apps it is linked to are named. Unlink them first.

### print the service information

```shell
# usage
dokku elasticsearch:info [<service>] [--info-flags...]
```

flags:

- `--backend`: show the execution backend the service was created with
- `--backup-auth-fingerprint`: show a sha256 fingerprint of the stored backup access key id and secret
- `--backup-authenticated`: show whether backup credentials are stored for the service
- `--backup-bucket`: show the bucket scheduled backups are shipped to
- `--backup-default-region`: show the region backups authenticate against
- `--backup-encrypted`: show whether scheduled backups are encrypted with a passphrase
- `--backup-encryption-fingerprint`: show a sha256 fingerprint of the stored backup passphrase
- `--backup-endpoint-url`: show the s3-compatible endpoint backups are shipped to
- `--backup-keyserver`: show the keyserver backup public keys are fetched from
- `--backup-public-key-id`: show the gpg public key id backups are encrypted with
- `--backup-schedule`: show the cron schedule backups run on
- `--backup-signature-version`: show the signature version backups authenticate with
- `--backup-use-iam`: show whether scheduled backups authenticate with an instance role
- `--config-dir`: show the service configuration directory
- `--config-options`: show the config options the service container is run with
- `--custom-env`: show the custom environment the service container is run with
- `--data-dir`: show the service data directory
- `--database-name`: show the name of the database inside the service
- `--definition`: show the definition the service was created with
- `--dsn`: show the service DSN
- `--export-args`: show the extra arguments every export of the service is run with
- `--expose-address`: show the address exposed ports without one of their own are published on
- `--expose-source-range`: show the only range of client addresses the exposed ports accept
- `--exposed-ports`: show service exposed ports
- `--id`: show the service container id
- `--image`: show the image the service runs
- `--image-version`: show the image version the service was created with
- `--import-args`: show the extra arguments every import into the service is run with
- `--initial-network`: show the initial network being connected to
- `--internal-ip`: show the service internal ip
- `--links`: show the service app links
- `--log-driver`: show the docker logging driver the service container is run with
- `--log-opt`: show the docker log options the service container is run with
- `--memory`: show the memory limit the service container is run with
- `--mounts`: show the host paths and docker volumes mounted into the service container
- `--post-create-network`: show the networks to attach to after service container creation
- `--post-start-network`: show the networks to attach to after service container start
- `--restart-policy`: show the restart policy the service container is run with
- `--service`: show the name of the service
- `--service-root`: show the service root directory
- `--shm-size`: show the shared memory size the service container is run with
- `--status`: show the service running status
- `--version`: show the service image version
- `--wait-timeout`: show the seconds the service is waited on to become ready

Get connection information as follows:

```shell
dokku elasticsearch:info lollipop
```

Alongside the connection information this reports the properties set on the service, the state it was created with, and its backup settings. A property that was never set, or that was unset, reports as empty. Omit the service to report on every elasticsearch service:

```shell
dokku elasticsearch:info
```

The information can be read by machine, one json object per service:

```shell
dokku elasticsearch:info lollipop --format json
```

You can also retrieve a specific piece of service info via a flag, which prints it on its own:

```shell
dokku elasticsearch:info lollipop --dsn
dokku elasticsearch:info lollipop --status
dokku elasticsearch:info lollipop --initial-network
```

> NOTE: a flag cannot be combined with --format, and only one may be given

The properties elasticsearch:set writes are reported under the names it takes, so a value read here can be written back:

```shell
dokku elasticsearch:set lollipop initial-network my-network
```

The stored backup credentials and passphrase are never printed. Each is reported as a lowercase hex sha256 fingerprint of the stored value, with surrounding whitespace trimmed, so a copy of the values can be compared against it:

```shell
dokku elasticsearch:info lollipop --backup-auth-fingerprint
dokku elasticsearch:info lollipop --backup-encryption-fingerprint
```

The same fingerprints can be computed from the values that were passed to backup-auth and backup-set-encryption:

```
printf '%s\n%s' "$AWS_ACCESS_KEY_ID" "$AWS_SECRET_ACCESS_KEY" | sha256sum
printf '%s' "$PASSPHRASE" | sha256sum
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

- `-a|--alias <string>`: the prefix of the config variable the service url is set as on the app, which is suffixed with _URL
- `-n|--no-restart`: whether to skip restarting the app
- `-q|--querystring <string>`: ampersand delimited querystring arguments to append to the service url after a ?

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

The url can be set under another name with the `--alias` flag. The value given is the prefix of the config variable, which is suffixed with `_URL` and holds the same url:

```shell
dokku elasticsearch:link lollipop playground --alias BLUE_ELASTICSEARCH
```

This will set the following on the linked application instead of `ELASTICSEARCH_URL`:

```
BLUE_ELASTICSEARCH_URL=http://:SOME_PASSWORD@dokku-elasticsearch-lollipop:9200
```

An alias whose variable is already set on the app is refused, and unlink removes the variable whatever alias it was set under. Arguments can be appended to the url as a querystring with the `--querystring` flag:

```shell
dokku elasticsearch:link lollipop playground --querystring "foo=bar&baz=qux"
```

This will cause `ELASTICSEARCH_URL` to be set as:

```
http://:SOME_PASSWORD@dokku-elasticsearch-lollipop:9200?foo=bar&baz=qux
```

It is possible to change the protocol for `ELASTICSEARCH_URL` by setting the environment variable `ELASTICSEARCH_DATABASE_SCHEME` on the app. Doing so after linking means unlink no longer finds the variable it set, and leaves it in place, so we advise you to unlink before proceeding.

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

An app is still linked after its `ELASTICSEARCH_URL` is changed to point elsewhere, and is unlinked the same way. The variable it now holds is not the service's, so it is left alone, nothing is unset, the app is not restarted, and a warning says so.

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

Cap the container log at a size of your own rather than the one it inherits:

```shell
dokku elasticsearch:set lollipop log-opt max-size=20m,max-file=3
```

Keep the log unbounded, which is what a service had before there was anything to say here:

```shell
dokku elasticsearch:set lollipop log-opt max-size=unlimited
```

Send the container log somewhere other than the daemon's own driver:

```shell
dokku elasticsearch:set lollipop log-driver journald
```

Restart the container unless it was stopped on purpose, including across a docker restart:

```shell
dokku elasticsearch:set lollipop restart-policy unless-stopped
```

Go back to always restarting the container:

```shell
dokku elasticsearch:set lollipop restart-policy
```

Wait up to two minutes for the service to answer, used the next time it is started:

```shell
dokku elasticsearch:set lollipop wait-timeout 120
```

Go back to the wait timeout the host or the datastore sets:

```shell
dokku elasticsearch:set lollipop wait-timeout
```

Publish exposed ports that have no address of their own on one address rather than on every interface:

```shell
dokku elasticsearch:set lollipop expose-address 10.0.0.5
```

Only accept connections to the exposed ports from clients in one `IP` address or `CIDR`:

```shell
dokku elasticsearch:set lollipop expose-source-range 10.0.0.0/8
```

Go back to accepting every client:

```shell
dokku elasticsearch:set lollipop expose-source-range
```

> NOTE: a log setting or a restart policy reaches the container the next time one is built. elasticsearch:restart keeps the container it has, so use elasticsearch:stop and then elasticsearch:start on a service that is already running.
> NOTE: an expose-address or expose-source-range reaches an exposed service with elasticsearch:reexpose, which replaces the container publishing its ports and leaves the service container running.

### mount a host path or docker volume into the service container

```shell
# usage
dokku elasticsearch:mount [--replace] <service> <source:container-dir[:options]>...
```

flags:

- `--replace`: replace the service's entire set of mounts with the ones given
- `--volume-chown <string>`: who to hand the mounted directory to, for a host path inside the service's directory; not valid with --replace
- `--volume-options <string>`: comma-separated docker mount options, such as z or nocopy; not valid with --replace
- `--volume-readonly`: mount the volume read only; not valid with --replace
- `--volume-subpath <string>`: a subpath within the source to mount rather than the source itself; not valid with --replace

Mount a host directory into the service container:

```shell
dokku elasticsearch:mount lollipop /var/lib/dokku/data/storage/lollipop:/opt/extra
```

The source is an absolute host path, which must already exist, or the name of a docker volume. Options follow a second colon: ro or rw, docker's own mount options, volume-subpath=<path> and volume-chown=<option>:

```shell
dokku elasticsearch:mount lollipop /var/lib/dokku/data/storage/lollipop:/opt/extra:ro,z
```

A subpath mounts a directory within the source rather than the source itself. A docker volume mounted from a subpath needs Docker Engine 26.0 or newer, and takes no mount option but nocopy.

```shell
dokku elasticsearch:mount lollipop my-volume:/opt/extra:volume-subpath=uploads
```

A chown hands the mounted directory to a user before the container is made: herokuish, heroku, paketo, root or a uid. It is only taken for a host path inside the service's own directory.

```shell
dokku elasticsearch:mount lollipop /var/lib/dokku/services/elasticsearch/lollipop/extra:/opt/extra:volume-chown=heroku
```

The same can be said with flags instead:

```shell
dokku elasticsearch:mount lollipop /var/lib/dokku/data/storage/lollipop:/opt/extra --volume-readonly --volume-options z
```

Mounting the same source at the same directory again rewrites its options:

```shell
dokku elasticsearch:mount lollipop /var/lib/dokku/data/storage/lollipop:/opt/extra
```

Replace every mount the service has with the ones given:

```shell
dokku elasticsearch:mount --replace lollipop /srv/a:/opt/a:ro /srv/b:/opt/b
```

> NOTE: a mount reaches the container the next time one is built. elasticsearch:restart keeps the container it has, so use elasticsearch:stop and then elasticsearch:start on a service that is already running.

### remove one or all mounts from the service container

```shell
# usage
dokku elasticsearch:unmount [--all] <service> [<source:container-dir>...]
```

flags:

- `--all`: remove every mount the service has

Remove a mount, naming it the way it was mounted:

```shell
dokku elasticsearch:unmount lollipop /var/lib/dokku/data/storage/lollipop:/opt/extra
```

Remove every mount the service has:

```shell
dokku elasticsearch:unmount --all lollipop
```

> NOTE: the mount is removed from the container the next time one is built. elasticsearch:restart keeps the container it has, so use elasticsearch:stop and then elasticsearch:start on a service that is already running.

### Service Lifecycle

The lifecycle of each service can be managed through the following commands:

### enter or run a command in a running Elasticsearch service container

```shell
# usage
dokku elasticsearch:enter <service>
```

A shell can be opened against a running service. Filesystem changes will not be saved to disk.

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

Expose the service on random ports on a single address, and only to clients in one network:

```shell
dokku elasticsearch:set lollipop expose-address 10.0.0.5
dokku elasticsearch:set lollipop expose-source-range 10.0.0.0/8
dokku elasticsearch:expose lollipop
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

### reexpose a Elasticsearch service, applying its expose settings without restarting it

```shell
# usage
dokku elasticsearch:reexpose <service>
```

Apply a changed expose-address or expose-source-range to an exposed service, on the ports it is already exposed on:

```shell
dokku elasticsearch:set lollipop expose-source-range 10.0.0.0/8
dokku elasticsearch:reexpose lollipop
```

> NOTE: only the container publishing the service's ports is replaced, so the service keeps running, though connections made through the exposed ports are dropped. A service that is not exposed, or is not running, is refused.

### promote service <service> as ELASTICSEARCH_URL in <app>

```shell
# usage
dokku elasticsearch:promote <service> [<app>]
```

If you have a elasticsearch service linked to an app and try to link another elasticsearch service another link environment variable will be generated automatically:

```
DOKKU_ELASTICSEARCH_AQUA_URL=http://:ANOTHER_PASSWORD@dokku-elasticsearch-other-service:9200/other_service
```

You can promote the new service to be the primary one:

> NOTE: this will restart your app

```shell
dokku elasticsearch:promote other_service playground
```

This will replace `ELASTICSEARCH_URL` with the url from other_service and generate another environment variable to hold the previous value if necessary. You could end up with the following for example:

```
ELASTICSEARCH_URL=http://:ANOTHER_PASSWORD@dokku-elasticsearch-other-service:9200/other_service
DOKKU_ELASTICSEARCH_AQUA_URL=http://:ANOTHER_PASSWORD@dokku-elasticsearch-other-service:9200/other_service
DOKKU_ELASTICSEARCH_BLACK_URL=http://:SOME_PASSWORD@dokku-elasticsearch-lollipop:9200/lollipop
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

A service comes back on the version it was created with, or was last upgraded to, whatever version the plugin ships now. The image is fetched if the host no longer has it. A service that has never recorded a version and has no container left to read one from cannot be placed, and is reported rather than started on a guess. Use elasticsearch:upgrade to say which version it should run.

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

- `-c|--config-options <string>`: extra arguments for the process the service container runs, not docker flags; use mount for mounts
- `-C|--custom-env <string>`: semi-colon delimited environment variables to start the service with
- `-i|--image <string>`: the image to upgrade the service to
- `-I|--image-version <string>`: the image version to upgrade the service to
- `-N|--initial-network <string>`: the initial network to attach the service to
- `--log-driver <string>`: the docker logging driver to run the service container with (default: the daemon's own)
- `--log-opt <strings>`: a comma-separated list of key=value docker log options for the service container
- `-m|--memory <int>`: container memory limit in megabytes, 0 for unlimited
- `-P|--post-create-network <strings>`: a comma-separated list of networks to attach the service container to after service creation
- `-S|--post-start-network <strings>`: a comma-separated list of networks to attach the service container to after service start
- `--restart <string>`: the docker restart policy to run the service container with (default: always)
- `-R|--restart-apps`: whether to stop and start the linked apps around the upgrade
- `-s|--shm-size <string>`: override shared memory size for the service docker container
- `--volume <stringArray>`: a host path or docker volume to mount into the service container, as <source>:<container-dir>[:<options>], repeatable
- `--wait-timeout <string>`: seconds to wait for the service to become ready (default: the datastore's own)

You can upgrade an existing service to a new image or image-version:

```shell
dokku elasticsearch:upgrade lollipop
```

This is the only command that changes the version a service runs. With no version named it moves to the newest the service's own major version ships, which leaves the data where it is.

```shell
dokku elasticsearch:upgrade lollipop --image-version 1.2.3
```

Moving across a major version has to be asked for by name, because it is not a tag change: the data is mounted somewhere different under the new one, and pointing the version back does not undo it. A service keeps the mounts it has unless --volume is passed, which replaces them, and each one is checked against the new container before the old one is taken away.

```shell
dokku elasticsearch:upgrade lollipop --volume /var/lib/dokku/data/storage/lollipop:/opt/extra:ro
```

A service keeps its memory limit unless --memory is passed, and --memory 0 removes it.

```shell
dokku elasticsearch:upgrade lollipop --memory 512
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

Renaming an app moves its link onto the new name, and cloning an app links the clone as well as the original.

### Limiting where and to whom a service is exposed

An exposed service's ports are published on every interface unless they are given an address of their own. To publish them on one address instead, set the service's `expose-address` property with `dokku elasticsearch:set`, and to accept connections only from clients in one IP address or CIDR, set its `expose-source-range` property. Either reaches a running service with `dokku elasticsearch:reexpose`, which leaves the service running.

Only one source range can be given. The range is checked against the address a connection reaches the service from, which for a connection to the exposed port on the loopback interface, or an IPv6 connection to a service network without IPv6, is the docker network's gateway rather than the client, so with a range that leaves the gateway out, connecting to `127.0.0.1` from the dokku host itself is refused.

### Waiting for a service to become ready

A service is waited on until it answers on its port after it is created, cloned, started, restarted, upgraded or exposed. If it takes longer than that to start - on a slow host, or with an image that does more on its first boot - the command fails with `ERROR: unable to connect`.

To wait longer for every elasticsearch service on the host, set the `ELASTICSEARCH_WAIT_TIMEOUT` environment variable to a number of seconds. To wait longer for a single service, set its `wait-timeout` property with `dokku elasticsearch:set` or pass `--wait-timeout` to `create`, `clone` or `upgrade`. The service's own setting is used first, then the environment variable, then the datastore's default.

### Disabling `docker image pull` calls

If you wish to disable the `docker image pull` calls that the plugin triggers, you may set the `ELASTICSEARCH_DISABLE_PULL` environment variable to `true`. Once disabled, you will need to pull the service image you wish to deploy as shown in the `stderr` output.

Please ensure the proper images are in place when `docker image pull` is disabled.
