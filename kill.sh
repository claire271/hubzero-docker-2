#!/bin/bash

docker kill -it $(docker ps -q)
