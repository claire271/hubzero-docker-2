#!/bin/bash

if [ ! -d hubzero-cms ]; then
	git clone https://github.com/hubzero/hubzero-cms
fi
docker build -t hubzero_cms .
