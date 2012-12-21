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


