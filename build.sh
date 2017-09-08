#!/bin/bash

if [ ! -d hubzero-cms ]; then
	git clone https://github.com/hubzero/hubzero-cms
	#cd hubzero-cms
	#git checkout 2.1.10
	#cd ..
fi
docker build -t hubzero_cms .
