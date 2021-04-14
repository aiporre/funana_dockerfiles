# Docker ubuntufunana

Basic user ubuntufunana have the basic programs and access to the SDS

**To run:**
``` bash

docker run -it --name ubuntufunana1 --gpus all --hostname terminalserver --cap-add=SYS_ADMIN --cap-add DAC_READ_SEARCH --security-opt apparmor:unconfined --shm-size 1g -p 33895:3389 -p 2225:22 ubuntufunana:latest

```
