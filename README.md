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
