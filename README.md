# Hoccer Deployment

## Prerequisites

* rvm must be installed

*Note:* Developed and tested on OS X

## Setup

Enter directory and first link up the `.ruby*` files:

<pre>
$ ln -s .ruby-version.dev .ruby-version
$ ln -s .ruby-gemset.dev .ruby-gemset
$ cd . # to activate this setting
</pre>

Then install all required gems via

<pre>
$ bundle
</pre>

## SSH Key exchange

The deployment requires that you can passwordless ssh to the respective 
deployment target as the deployment user (`deployment`). For this to work 
automatically your ssh-pub-key must be present in the `authorized_keys` file of the user `deployment`.

<pre>
$ vagrant ssh
$ sudo su deployment
$ mkdir .ssh
$ vim .ssh/authorized_keys  // copy your pub-key into here
</pre>

Exit the appliance and check if passwordless login is setup:

<pre>
$ ssh deployment@192.168.60.10
</pre>

## Releases (on Github)

### Preparing a release

A Release is defined as github release where the tag name is `<product-name>-<version>`

The deployment process can either automatically select the most current release or a specific version can be deployed.

A release is available for deployment if the following conditions are true:

* At least one asset is attached to the release
* All assets have the state `uploaded` (which usually is the case as soon as the asset is uploaded - in fact we were unable to find what other states even exist)
* Exactly one asset has a file ending of `.jar`. This asset is assumed to be the actualy executable. Other assets are also deployed but the executable asset is linked to `<product-name>.jar` so the start-up scripts know which file to actually start.

Not covered here is a description on how to actually generate the release assets of a release. This is part of the packaging instruction of the respective product.

### Accessing the releases with the deployment scripts

Since we have private repositories the releases are also private. To access them during deployment authentication to github has to be provided.

This is done by creating a file named `secrets.yml` in the directory `config`. Supply your github username and authentication token in there. Consult the file `config/secrets.yml_template` on how to format the file.

It is strongly recommended to create a personal access token (via https://github.com/settings/applications) which has only the following scopes set: `repo` and `public_repo`. Please do not use you password as token!

## Upstart Scripts

The services supplied here come with upstart scripts that should be placed in `/etc/init`.

For every such service a symlink from `/lib/init/upstart-job` to `/etc/init.d/<service_name>` has to be created as well:
<pre>
$ sudo ln -s /lib/init/upstart-job /etc/init.d/filecache
</pre>

The presence of the upstart scripts is a prerequisite of the deployment. The deployment process itself will not automatically install those. This a one-time administrative task.

The upstart file for a service can be found in the `upstart` sub-directory of the respective service's deployment folder.

## Configuring services

The services require configuration files which are not part of the deployment process but need to copied manually. For details about the configuration files and their contents consult the respective service's instructions.

It can be seen in the upstart script where the config file should reside (actually in the `shared/config` subfolder which is initially created via `deploy:setup`).

## Deploying

### Preparation a target machine

* In the directory of the service (product) you want to deploy execute:
<pre>
$ cap &lt;stagename&gt; deploy:setup
$ cap &lt;stagename&gt; deploy:check
</pre>

### Create the service's config-file

* create the service's configuration file at `shared/config/settings.conf` (find a template in the service's repo)

### Deploying latest version of a service

* In the directory of the service you want to deploy execute:
<pre>
$ cap &lt;stagename&gt; deploy
</pre>

### Deploying a specific version of a service

* In the directory of the service you want to deploy execute:
<pre>
$ cap &lt;stagename&gt; deploy -s product_version=&lt;version&gt;
</pre>

This will set the capistrano variable `product_version` to a value and not automatically determine the lastest release's version string.

If no release exists for the specified version the deployment process will abort with an appropriate message, e.g.:

<pre>
** Selecting release for specificed version: '2.0.0'...
*** No deployable release acquired! ABORTING
</pre>

### Version information metadata

All releases carry a file `version` that contains just the version string of the deployed release.

## Custom nginx setup

Find documentation [here](https://github.com/hoccer/vagrant-appliance/wiki/Nginx-setup)

## Helper rake tasks

Get a full list of the tasks by executing `rake -T`

* `latest`
  This task lists the latest deployable relaeas for all known products

* `list`
  This task lists all releases of all known products along some additional information about deployability.

* `fetch`
  Fetches the assets associated with the latest_release to a `tmp` directory (top-level)

## Development setup

For development purposes only guard and rubocop are used.

Any development should be accompanied by having

<pre>
$ bundle exec guard
</pre>

running in a console. Currently this only monitors code-style of the ruby code according to a sane standard. In the future additionally tests with rspec are possible.
