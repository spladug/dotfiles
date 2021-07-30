#!/bin/bash

set -e -x

apt-get update
apt-get install -y node-typescript make libglib2.0-bin
make -C shell/ depcheck compile
