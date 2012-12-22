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
If you want to user sentry include recipe[sentry] to you runlist.

Replace you own `node['sentry']['key']` random key.

For create new superusers you need overrider `node['sentry']['superusers']` attribute:

    "superusers" => [{
                     "username" => "alex",
                     "password" => "tmppassword",
                     "email" => "alex@obout.ru"}]

We recommend change temporary passwords after from web interface.

To configure database override `node['sentry']['databases']['default']` keys:

     "databases" => {
        "default" => {
          "NAME" => "/var/www/sentry/sentry.db"
        },
     }


See also
========

- [Exceptional error aggregation](https://github.com/getsentry/)