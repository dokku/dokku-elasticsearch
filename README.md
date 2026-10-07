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
elasticsearch:reexpose <service>                   # reexpose a Elasticsearch service, applying its expose settings
elasticsearch:reset <service> [-f|--force]         # delete all data in the Elasticsearch service, keeping the service and its links
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
- `--definition <string>`: the definition to run the service on, instead of the one its image and version resolve to
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
- `--volume-target <stringArray>`: mount one of the definition's volumes at another container path, as <volume>=<container-dir>, repeatable
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

The definition a service runs on decides where its data is mounted, and is otherwise worked out from the image and version. An image whose tags do not carry the major version can name one outright, and --image and --image-version are laid over the image and version it ships. The definitions are: elasticsearch-7, elasticsearch-8, elasticsearch-9.

```shell
export ELASTICSEARCH_DEFINITION="elasticsearch-7"
dokku elasticsearch:create lollipop --definition elasticsearch-7 --image <image> --image-version <version>
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

The definition's own volumes can be mounted at another path in the container, for an image that keeps its data somewhere else, with --volume-target, which may be repeated.

```shell
export ELASTICSEARCH_VOLUME_TARGETS="data=/srv/elasticsearch"
dokku elasticsearch:create lollipop --volume-target data=/srv/elasticsearch
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
- `--backup-mailto`: show who cron mails the output of scheduled backups to in place of the global MAILTO
- `--backup-object-name`: show the name backups are uploaded under in place of the default
- `--backup-public-key-id`: show the gpg public key id backups are encrypted with
- `--backup-schedule`: show the cron schedule backups run on
- `--backup-signature-version`: show the signature version backups authenticate with
- `--backup-storage-class`: show the s3 storage class backups are uploaded with
- `--backup-timestamp`: show whether backups are uploaded under a key ending in the time they started
- `--backup-use-iam`: show whether scheduled backups authenticate with an instance role
- `--config-dir`: show the service configuration directory
- `--config-options`: show the config options the service container is run with
- `--custom-env`: show the custom environment the service container is run with
- `--data-dir`: show the service data directory
- `--database-name`: show the name of the database inside the service
- `--definition`: show the definition the service was created with
- `--dsn`: show the service DSN
- `--export-args`: show the extra arguments every export of the service is run with
- `--expose-host`: show the host the exposed DSN names
- `--expose-mode`: show whether exposed ports are published through an ambassador or directly by the service container
- `--exposed-dsn`: show the DSN the service is reached at through its exposed ports
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
- `--port-bind-address`: show the address exposed ports without one of their own are bound on
- `--port-source-range`: show the only range of client addresses the exposed ports accept
- `--post-create-network`: show the networks to attach to after service container creation
- `--post-start-network`: show the networks to attach to after service container start
- `--restart-policy`: show the restart policy the service container is run with
- `--service`: show the name of the service
- `--service-root`: show the service root directory
- `--shm-size`: show the shared memory size the service container is run with
- `--status`: show the service running status
- `--version`: show the service image version
- `--volume-targets`: show the container paths the service's volumes are mounted at in place of the definition's
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
dokku elasticsearch:info lollipop --internal-ip
dokku elasticsearch:info lollipop --initial-network
```

> NOTE: a flag cannot be combined with --format, and only one may be given

The exposed dsn is the one a client off the host connects with. It names the expose-host, or the first global domain without one, and is empty until the service is exposed and there is a host to name:

```shell
dokku elasticsearch:info lollipop --exposed-dsn
```

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
- `-e|--env-var <string>`: the full name of the config variable the service url is set as on the app, used instead of an alias and not suffixed with _URL
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

An alias whose variable is already set on the app is refused, and unlink removes the variable whatever alias it was set under. An app that expects the url under a name that does not end in `_URL` can be given that name in full with the `--env-var` flag, which cannot be combined with `--alias`:

```shell
dokku elasticsearch:link lollipop playground --env-var MB_DB_CONNECTION_URI
```

This will set the following on the linked application instead of `ELASTICSEARCH_URL`:

```
MB_DB_CONNECTION_URI=http://:SOME_PASSWORD@dokku-elasticsearch-lollipop:9200
```

A name already set on the app is refused. Arguments can be appended to the url as a querystring with the `--querystring` flag:

```shell
dokku elasticsearch:link lollipop playground --querystring "foo=bar&baz=qux"
```

This will cause `ELASTICSEARCH_URL` to be set as:

```
http://:SOME_PASSWORD@dokku-elasticsearch-lollipop:9200?foo=bar&baz=qux
```

It is possible to change the protocol for `ELASTICSEARCH_URL` by setting the environment variable `ELASTICSEARCH_DATABASE_SCHEME` on the app. Link records the variable it set, so unlink still removes it after the scheme or querystring on it changes. A link made by an earlier version of the plugin is recorded the next time link or promote runs for it, and until then we advise you to unlink before changing the scheme.

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

An app is still linked after its `ELASTICSEARCH_URL` is changed to point elsewhere, and is unlinked the same way. The variable it now holds is not the service's, so it is left alone, nothing is unset, the app is not restarted, and a warning says so. A variable link set that has only had its scheme or querystring changed still points at the service, and is unset.

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

Set the s3 storage class backups are uploaded with, one of `STANDARD,` `REDUCED_REDUNDANCY,` `STANDARD_IA,` `ONEZONE_IA,` `INTELLIGENT_TIERING,` `GLACIER,` `DEEP_ARCHIVE` or `GLACIER_IR`:

```shell
dokku elasticsearch:set lollipop backup-storage-class STANDARD_IA
```

Go back to uploading backups with the bucket's default storage class:

```shell
dokku elasticsearch:set lollipop backup-storage-class
```

Upload backups under a name of your own rather than elasticsearch-lollipop:

```shell
dokku elasticsearch:set lollipop backup-object-name db/latest
```

Upload every backup to the same key, without a timestamp, so bucket versioning and lifecycle rules can keep and rotate them:

```shell
dokku elasticsearch:set lollipop backup-timestamp false
```

Go back to timestamped backups:

```shell
dokku elasticsearch:set lollipop backup-timestamp
```

Mail the output of scheduled backups to a comma-separated list of email addresses or local users rather than to the global cron `MAILTO`. Requires a dokku version that reads json entries from the cron-entries plugin trigger, and a mail transfer agent on the host:

```shell
dokku elasticsearch:set lollipop backup-mailto ops@example.com,dba@example.com
```

Go back to mailing scheduled backup output to the global cron `MAILTO`:

```shell
dokku elasticsearch:set lollipop backup-mailto
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
dokku elasticsearch:set lollipop port-bind-address 10.0.0.5
```

Only accept connections to the exposed ports from clients in one `IP` address or `CIDR`:

```shell
dokku elasticsearch:set lollipop port-source-range 10.0.0.0/8
```

Go back to accepting every client:

```shell
dokku elasticsearch:set lollipop port-source-range
```

Name the host the exposed dsn points clients at, when they reach the server by a name or address other than its global domain. It does not change where the ports are bound:

```shell
dokku elasticsearch:set lollipop expose-host db.example.com
```

Go back to naming the first global domain:

```shell
dokku elasticsearch:set lollipop expose-host
```

Publish the exposed ports on the service container itself rather than through an ambassador container, which relays every connection. A port-source-range cannot be used with it:

```shell
dokku elasticsearch:set lollipop expose-mode direct
```

Go back to publishing the exposed ports through an ambassador container:

```shell
dokku elasticsearch:set lollipop expose-mode
```

Mount one of the definition's volumes at another path in the container, for an image that keeps its data somewhere else. Each volume is named by where it lives in the service directory (config, data), and several are separated by spaces:

```shell
dokku elasticsearch:set lollipop volume-targets data=/srv/elasticsearch
```

Go back to mounting every volume where the definition does:

```shell
dokku elasticsearch:set lollipop volume-targets
```

> NOTE: a log setting, a restart policy or a volume target reaches the container the next time one is built. elasticsearch:restart keeps the container it has, so use elasticsearch:stop and then elasticsearch:start on a service that is already running.
> NOTE: a port-bind-address or port-source-range reaches an exposed service with elasticsearch:reexpose, which replaces the container publishing its ports and leaves the service container running.
> NOTE: an expose-mode, or a port-bind-address for a service exposed directly, reaches an exposed service with elasticsearch:reexpose, which stops and starts a running service after asking. It also reaches the service the next time it is restarted, or stopped and started.

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

> NOTE: a mount cannot land where one of the definition's volumes is mounted, which for a volume moved with the volume-targets property is where it was moved to.
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

flags:

- `-f|--force`: stop and start a running service without asking when its container has to publish other ports

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
dokku elasticsearch:set lollipop port-bind-address 10.0.0.5
dokku elasticsearch:set lollipop port-source-range 10.0.0.0/8
dokku elasticsearch:expose lollipop
```

Expose the service by publishing its ports on the service container itself rather than through an ambassador container. A running service is stopped and started to publish them, after asking, or without asking when --force is given:

```shell
dokku elasticsearch:set lollipop expose-mode direct
dokku elasticsearch:expose lollipop --force
```

Print the dsn a client off the host connects with, which names the expose-host or the first global domain:

```shell
dokku elasticsearch:info lollipop --exposed-dsn
```

### unexpose a previously exposed Elasticsearch service

```shell
# usage
dokku elasticsearch:unexpose <service>
```

flags:

- `-f|--force`: stop and start a running service without asking when its container has to publish other ports

Unexpose the service, removing access to it from the public interface (`0.0.0.0`):

```shell
dokku elasticsearch:unexpose lollipop
```

Unexpose a running service exposed directly, stopping and starting it without asking so that its container stops publishing the ports:

```shell
dokku elasticsearch:unexpose lollipop --force
```

### reexpose a Elasticsearch service, applying its expose settings

```shell
# usage
dokku elasticsearch:reexpose <service>
```

flags:

- `-f|--force`: stop and start a running service without asking when its container has to publish other ports

Apply a changed port-bind-address or port-source-range to an exposed service, on the ports it is already exposed on:

```shell
dokku elasticsearch:set lollipop port-source-range 10.0.0.0/8
dokku elasticsearch:reexpose lollipop
```

Move an exposed service between being published through an ambassador and directly, stopping and starting it without asking:

```shell
dokku elasticsearch:set lollipop expose-mode direct
dokku elasticsearch:reexpose lollipop --force
```

> NOTE: a service published through an ambassador only has the ambassador replaced, so the service keeps running, though connections made through the exposed ports are dropped. An ambassador that already matches the service's settings and is publishing is left alone.
> NOTE: a service whose container has to publish other ports, because it is exposed directly or is being moved between expose modes, is stopped and started. A running service is asked about first, and nothing is changed if the answer is no.
> NOTE: A service that is not exposed is refused, as is one published through an ambassador that is not running.

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
- `--definition <string>`: the definition to move the service onto, instead of the one its image and version resolve to
- `-i|--image <string>`: the image to upgrade the service to
- `-I|--image-version <string>`: the image version to upgrade the service to
- `-N|--initial-network <string>`: the initial network to attach the service to
- `--log-driver <string>`: the docker logging driver to run the service container with (default: the daemon's own)
- `--log-opt <strings>`: a comma-separated list of key=value docker log options for the service container
- `-m|--memory <int>`: container memory limit in megabytes, 0 for unlimited
- `-P|--post-create-network <strings>`: a comma-separated list of networks to attach the service container to after service creation
- `-S|--post-start-network <strings>`: a comma-separated list of networks to attach the service container to after service start
- `--restart <string>`: the docker restart policy to run the service container with (default: always)
- `-R|--restart-apps`: whether to stop and start the linked apps around the upgrade, required for one that migrates the data
- `-s|--shm-size <string>`: override shared memory size for the service docker container
- `--volume <stringArray>`: a host path or docker volume to mount into the service container, as <source>:<container-dir>[:<options>], repeatable
- `--volume-target <stringArray>`: mount one of the definition's volumes at another container path, as <volume>=<container-dir>, repeatable
- `--wait-timeout <string>`: seconds to wait for the service to become ready (default: the datastore's own)

You can upgrade an existing service to a new image or image-version:

```shell
dokku elasticsearch:upgrade lollipop
```

This is the only command that changes the version a service runs. With no version named it moves to the newest the service's own major version ships, which leaves the data where it is.

```shell
dokku elasticsearch:upgrade lollipop --image-version 1.2.3
```

Moving across a major version has to be asked for by name, because it is not a tag change: the data is mounted somewhere different under the new one, and pointing the version back does not undo it. A service can also be moved onto a definition by name, with --image and --image-version laid over the image and version it ships. This moves where the data is mounted in the same way, even when the image stays the same.

```shell
dokku elasticsearch:upgrade lollipop --definition elasticsearch-7
```

A service keeps the mounts it has unless --volume is passed, which replaces them, and each one is checked against the new container before the old one is taken away.

```shell
dokku elasticsearch:upgrade lollipop --volume /var/lib/dokku/data/storage/lollipop:/opt/extra:ro
```

A service keeps the volume targets it has unless --volume-target is passed, which replaces them, and an upgrade onto a definition that does not mount a volume the service moved is refused before the old container is taken away. --volume-target "" puts every volume back where the new definition mounts it.

```shell
dokku elasticsearch:upgrade lollipop --volume-target ""
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

### Data Management

The underlying service data can be imported and exported with the following commands:

### delete all data in the Elasticsearch service, keeping the service and its links

```shell
# usage
dokku elasticsearch:reset <service> [-f|--force]
```

flags:

- `-f|--force`: reset the service without asking for its name first

Delete all data in the service, leaving it as empty as a newly created one. The service, its credentials, and the apps it is linked to are kept, so linked apps do not need to be relinked. Connections the apps hold open may be closed.

```shell
dokku elasticsearch:reset lollipop
```

The service name is asked for before anything is deleted, unless --force is given:

```shell
dokku elasticsearch:reset lollipop --force
```

### Limiting where and to whom a service is exposed

An exposed service's ports are published on every interface unless they are given an address of their own. To publish them on one address instead, set the service's `port-bind-address` property with `dokku elasticsearch:set`, and to accept connections only from clients in one IP address or CIDR, set its `port-source-range` property. Either reaches a running service with `dokku elasticsearch:reexpose`, which leaves the service running when its ports are published through an ambassador.

Only one source range can be given. The range is checked against the address a connection reaches the service from, which for a connection to the exposed port on the loopback interface, or an IPv6 connection to a service network without IPv6, is the docker network's gateway rather than the client, so with a range that leaves the gateway out, connecting to `127.0.0.1` from the dokku host itself is refused.

### Exposing a service without an ambassador

An exposed service's ports are published by an ambassador, a container that relays every connection on to the service. The ambassador can be replaced without touching the service and can hold clients to a `port-source-range`, but relaying adds latency to every request.

To publish the ports on the service container itself instead, set the service's `expose-mode` property to `direct` with `dokku elasticsearch:set`. Docker has no way of changing the ports a container publishes, so the container is made again whenever what it publishes changes: when the service is exposed or unexposed, when its `port-bind-address` changes, and when it moves between expose modes. For a running service, `dokku elasticsearch:expose`, `dokku elasticsearch:unexpose` and `dokku elasticsearch:reexpose` ask before stopping and starting it, and change nothing if the answer is no. Pass `--force` to stop and start it without being asked. A change also reaches the service the next time it is restarted, or stopped and started.

A `port-source-range` cannot be enforced on a port the service container publishes itself, so it cannot be set on a service exposed directly, and a service with one cannot be exposed directly.

### Connecting to an exposed service from outside the host

`dokku elasticsearch:info lollipop --exposed-dsn` prints the dsn a client off the dokku host connects with. It is the dsn a linked app is handed, with the exposed ports in place of the container's and a public host in place of the service container's name, so it carries the same credentials. The host is the service's `expose-host` property, set with `dokku elasticsearch:set`, or the first global domain when it has none. The `port-bind-address`, or an address given with a port, is never used as the host, since it is where the port is bound rather than where a client elsewhere reaches it. The dsn is empty until the service is exposed and there is a host to name.

### Waiting for a service to become ready

A service is waited on until it answers on its port after it is created, cloned, started, restarted, upgraded or exposed. If it takes longer than that to start - on a slow host, or with an image that does more on its first boot - the command fails with `ERROR: unable to connect`.

To wait longer for every elasticsearch service on the host, set the `ELASTICSEARCH_WAIT_TIMEOUT` environment variable to a number of seconds. To wait longer for a single service, set its `wait-timeout` property with `dokku elasticsearch:set` or pass `--wait-timeout` to `create`, `clone` or `upgrade`. The service's own setting is used first, then the environment variable, then the datastore's default.

### Moving where a service's volumes are mounted

Each volume a service mounts is named by the directory it lives in under the service's own directory, and is mounted where the datastore's definition says. To mount one somewhere else in the container, for an image that keeps its data at another path, set the service's `volume-targets` property with `dokku elasticsearch:set`, pass `--volume-target` to `create`, `clone` or `upgrade`, or set the `ELASTICSEARCH_VOLUME_TARGETS` environment variable before `create`. Each is written as `<volume>=<container-path>`, several separated by spaces, and `dokku elasticsearch:info lollipop --volume-targets` shows the ones a service moved.

| Definition | Volume | Mounted at |
| --- | --- | --- |
| elasticsearch-7 | config | `/usr/share/elasticsearch/config` |
| elasticsearch-7 | data | `/usr/share/elasticsearch/data` |
| elasticsearch-8 | config | `/usr/share/elasticsearch/config` |
| elasticsearch-8 | data | `/usr/share/elasticsearch/data` |
| elasticsearch-9 | config | `/usr/share/elasticsearch/config` |
| elasticsearch-9 | data | `/usr/share/elasticsearch/data` |

Moving a volume changes where it is mounted, not where the image reads and writes. The datastore's own commands and the paths it is started with follow the volume, but an image that keeps writing to its own path writes into the container rather than into the volume, and what it writes is lost when the container is rebuilt, so only move a volume to where the image expects its data. The data stays in the same directory on the host, and a move reaches the container the next time one is built, so use `dokku elasticsearch:stop` and then `dokku elasticsearch:start` on a running service. An upgrade onto a definition that does not mount a volume the service moved is refused until the move is cleared or replaced.

### Disabling `docker image pull` calls

If you wish to disable the `docker image pull` calls that the plugin triggers, you may set the `ELASTICSEARCH_DISABLE_PULL` environment variable to `true`. Once disabled, you will need to pull the service image you wish to deploy as shown in the `stderr` output.

Please ensure the proper images are in place when `docker image pull` is disabled.
