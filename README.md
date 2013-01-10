Description
===========

Cookbook for setup and configure [sentry](http://github.com/getsentry/sentry) application.


Requirements
============

[python](https://github.com/opscode-cookbooks/python)

Attributes
==========

The sentry.conf.py file are dynamically generated from attributes.

All default values of attributes you can see in `attributes/default.rb`


Usage
=====
To use the cookbook we recommend creating a cookbook named after the application, e.g. my_app.
In metadata.rb you should declare a dependency on this cookbook:

depends "sentry"

Include ``recipe[sentry]`` to you runlist.


Replace you own ``node['sentry']['key']`` random key.

For create new superusers you need overrider `node['sentry']['superusers']` attribute:

    "superusers" => [{
                     "username" => "alex",
                     "password" => "tmppassword",
                     "email" => "alex@obout.ru"}]

We recommend change temporary passwords after from web interface.

To configure database override ``node['sentry']['databases']['default']`` keys:

     "databases" => {
        "default" => {
          "NAME" => "/var/www/sentry/sentry.db"
        },
     }


Add ``"recipe[sentry::instance]"`` to you runlist.

Or make you own custom configuration via resouces and definitions.

Create sentry config

    sentry_conf "sentry" do
        user "sentry"
        group "sentry"
        virtualenv node["sentry"]["virtualenv"]
        # Settings file variables hash
        settings {}
    end

Create launch instance:

    # Running sentry instance
    sentry_instance "sentry" do
        virtualenv node["sentry"]["virtualenv"]
        user node["sentry"]["user"]
        group node["sentry"]["group"]
        pidfile "/var/run/sentry-1.pid"
        config node["sentry"]["config"]
    end


Definitions
===========

You can create config for sentry need use definition ``sentry_conf``:

    sentry_conf "sentry" do
        user "sentry"
        group "sentry"
        virtualenv node["sentry"]["virtualenv"]
        # Settings file variables hash
        settings {}
    end

#### Attributes

- ``name`` name or path to config file (if config attr not used)
- ``template`` config template file name
- ``user`` user that own application
- ``group`` gtoup that own application
- ``config`` path to config file
- ``settings`` hash of config variables

Resources
=========

### sentry_instance

To run sentry instance you can user ``sentry_instance`` resouce

#### Attribute parameters

- ``name`` instance name
- ``group`` launch by group
- ``user`` launch by user
- ``virtualenv``: path to virtualenv
- ``config``: path to config file
- ``pidfile``: path to instance pidfile
- ``host``: host for binding
- ``port``: port for binging
- ``workers``: number of workers
- ``provider``: instance porvider (default: ``Chef::Provider::SentryBase``)

### Providers

sentry cookbook support 3 instance providers:

- ``Chef::Provider::SentryBase`` - simple provider, that create init.d script and spawn instance

- ``Chef::Provider::SentryRunit`` - provider, that spawn instance via ``runit``

- ``Chef::Provider::SentrySupervisor`` - provider, that spawn instance via ``supervisord``


Recipes
=======

default
-------

Base recipe to configure sentry user and group

instance
--------

Recipe to install simple sentry instance.


See also
========

- [Exceptional error aggregation](https://github.com/getsentry/)