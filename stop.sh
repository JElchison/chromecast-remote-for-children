#!/bin/bash

# don't use -e, since we want to stop as many things as possible
set -ufx

pkill node
sudo pkill -f 'sudo.*bgrep'
sudo pkill -f logkeys.log
sudo logkeys --kill
