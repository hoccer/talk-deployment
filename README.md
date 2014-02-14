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
