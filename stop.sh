#!/bin/bash

set -eufx

sudo logkeys --kill
sudo pkill -f 'sudo.*bgrep'
sudo pkill -f logkeys.log
