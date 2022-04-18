#!/usr/bin/env bash

# Download zip from URL and unzip

dir=$(dirname $1)
wget -q --show-progress -c -P $dir $2
unzip -n -d $dir $1
