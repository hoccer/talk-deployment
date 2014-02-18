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

The deployment requires that you can ssh to the respective deployment target as the deployment user (`deployment`). For this to work automatically your ssh-pub-key must be present in the `authorized_keys` file of the user `deployment`.

## Deploying

### Preparation a target machine

* In the directory of the service you want to deploy execute:
<pre>
$ cap &lt;stagename&gt; deploy:setup
$ cap &lt;stagename&gt; deploy:check
</pre>

### Deploying a service

* In the directory of the service you want to deploy execute:
<pre>
$ cap &lt;stagename&gt; deploy
</pre>

## Development setup

For development purposes only guard and rubocop are used.

Any developent should be accompanied by having

<pre>
$ bundle exec guard
</pre>

running in a console. Currently this only monitors code-style of the ruby code according to a sane standard. In the future additionally tests with rspec are possible.
