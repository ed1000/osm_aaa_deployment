#!/bin/bash

lxc stop keystone
lxc stop authentication
lxc stop authorization
lxc stop accounting

lxc delete keystone
lxc delete authentication
lxc delete authorization
lxc delete accounting
