#!/bin/bash

# Fix permissions
sudo find hubzero-cms ! -perm -111 -exec chmod 664 {} +
sudo find hubzero-cms -perm -111 -exec chmod 775 {} +

# Run container
docker run -e uid=$(id -u) -v $(pwd)/hubzero-cms:/var/www/example:rw -t hubzero_cms
