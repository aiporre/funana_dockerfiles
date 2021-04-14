#!/bin/bash

# run entry point of ubunturdp
sudo bash /usr/bin/docker-entrypoint.sh

# do more configurations...

echo "# Default configurations funana users: " | sudo tee -a /etc/profile
# for example add something to the PATH variable or run a script 
# echo "export PATH=$PATH" | sudo tee -a /etc/profile

exec "$@"
