#!/bin/bash

# run entry point of ubunturdp
sudo bash /usr/bin/docker-entrypoint.sh

# do more configurations...
echo "# Default configurations funana users: " >> /etc/profile

echo "export PATH=$PATH" >> /etc/profile

exec "$@"
