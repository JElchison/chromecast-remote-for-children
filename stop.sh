#!/bin/bash

# don't use -e, since we want to stop as many things as possible
set -ufx

pkill node
pkill -f bgrep
sudo logkeys --kill
pkill -f logkeys.log
