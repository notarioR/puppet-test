#!/bin/bash

echo "Starting puppet server"
/etc/init.d/puppetserver stop
/etc/init.d/puppetserver start
sleep infinity