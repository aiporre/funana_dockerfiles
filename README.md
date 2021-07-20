# Functional Anatomy Environments
Dockerfiles of working environments


## Standard usage

The containers in the stadard usage are configured to run on the top of `nvidia/cuda`. Please consider installing the nvidia-container toolkit the [official documentation](https://docs.nvidia.com/cuda/wsl-user-guide/index.html#setting-containers)

buiding the ubunturdp

1. This container has the rdp, session manager and ssh servers for users.
2. One user is defined by default `ubuntu` passwork `ubuntu`
3. By default build on the top of `nvidia/cuda:NVIDIATAG` with `NVIDIATAG` build argument set as `10.1-cudnn7-devel-ubuntu18.04`.
    1. Define a specific tag just add the argument `--build-arg NVIDIATAG=10.1-cudnn7-devel-ubuntu18.04`
    2. Tags are available in [the oficial nvidia docker hub](https://hub.docker.com/r/nvidia/cuda/tags)
    3. For example the build command would be:
    ```bash
    
    docker build --build-arg NVIDIATAG=11.2.0-cudnn8-devel-ubuntu18.04 -t ubunturdp:cuda11.2 .

    ```
    4. please keep the notation for the tag as `cuda[CUDA VERSION]-cudnn[cudnn version]-ubuntu[ubuntu distrib number]`


build the ubunufunana

1. This container has the conda and all the packages for the standard usage (n2v, stardist, ilastik..)
2. This depends on the ubuntu default tag is `cuda1x.y`
3. The build should also have the same tag so the build command for that example should look like: 
```bash

docker build --build-arg UBUNTURDPTAG=cuda11.2 -t ubuntufunana:cuda11.2 .

```

build the final user.

1. The final user is just build on the top the `ubuntufunana` image. You may make a copy of the folderl ubuntumyuser in this repository
2. modify the `etc/users.list` file to change the user name and passwork.
    1. First create a password running `openssl passwd -1 'whatever your password is..' ` and copy the hash in the given field at etc/users.list
    2. The structure of the `users.list` file is:
```bash
   id username password-hash list-of-supplemental-groups
```
 	3. In the groups it must be included `users`, otherwise the programs will not run for that user.
    4. Define the tag and keep the naming convesion `[new user]:[Tag of the ubuntufunana]`. In this example the command should be:
 
 ```bash
docker build --build-arg UBUNTUFUNANATAG=cuda11.2 -t user:cuda11.2 .
 ```


 Run your container with the command:

 ```bash
 docker run -it --name user --gpus all --hostname terminalserver --cap-add=SYS_ADMIN --cap-add DAC_READ_SEARCH --security-opt apparmor:unconfined --shm-size 64g -p 33895:3389 -p 2225:22 user:cuda11.2
 ```

 Allow the ports through the firewall with (has to be different for each user)
 ```bash
 sudo ufw allow 2225
 sudo ufw allow 33895
 ```


### shared data volume

```bash
    docker volume create --name shared --opt type=none --opt device=/mnt/data/Data --opt o=bind
```

```bash
    docker run -it --name user --gpus all --hostname terminalserver --cap-add=SYS_ADMIN --cap-add DAC_READ_SEARCH --security-opt apparmor:unconfined --shm-size 64g -p 33895:3389 -p 2225:22 -v shared:/mnt/data/Data user:cuda11.2
```
#### Optional steps

1. create a volume on a link in the data disk:
    1. Create directory in data: `mkdir -p /mnt/data/users/homes/myuser`
    2. Create the volume: 
    ```bash
    docker volume create --name homemyuser --opt type=none --opt device=/mnt/data/users/homes/myuser --opt o=bind
    docker volume create --name docker volume create --name homemyuser --opt type=none --opt device=/mnt/data/users/homes/myuser --opt o=bind --opt type=none --opt device=/mnt/data/users/homes/myuser --opt o=bind
    ```
    3. the command changes to:
    ```bash
    docker run -it --name ubuntumyuser --gpus all --hostname terminalserver --cap-add=SYS_ADMIN --cap-add DAC_READ_SEARCH --security-opt apparmor:unconfined --shm-size 1g -p 33895:3389 -p 2225:22 -v homemyuser:/home/myuser/ ubuntumyuser:cuda11.0-cudnn8-ubuntu18.04

    ```
	4. To connect (with remmina) use True Color 32 bpp Color depth.



TODOS:
[x] test n2v cuda11.0 fix ptxas notebook [OK]
[x] test n2v cuda11.2 notebook [OK]
[x] test cuda 11.0 stardist notebook 
[x] test cuda 11.2 stardist notebook 
[x] test deepstorm notebook cuda 11.0
[x] test deepstorm notebook cuda 11.2
[x] test cellpose notebook cuda 11.0
[x] test cellpose nmotebook cuda 11.2
[] install fiji plugins
[] install matlab 
[] install ubuntu-desktop


TODOS:
[x] Test noise to void it wont work here
    [x] chagne tag of quick-n2v to last version of n2v official repo
    [x] cuda 11.0 tf 2.4 test in a RXT3000?
    [x] Separate container n2v cuda11.0 with tf-cpu
    [x] Separate container n2v cuda11.2 with tf-gpu 
    [x] however if N2V decides to update to tf 2.5.0 then it will run in cuda11.1 and everythin will work.
[x] change cellpose to v0.6.2 (last version). before was using mxnet..mxnet doesn#t work with rx3000 series
[x] test stardist object and segmentation. change to cuda11.2 or use the workaround (better will be tf2.5 and cuda 11.2)
    [x] need to install nubios_academy.. create volume that connects mnt data Data 
    [x] update stadistcluster to tf2
[]x test elektron
    [x] runs in cuda 11.2?
    [x] runs in cuda 11.0?
[x] test deepstrorm
    [x] need to change tf 2.4.0 to 2.5.0
[x] install windows VMs
[] document how to change user name and password of the sds
[] terminal colors 256 support
[x] fix LD_LIBRARY_PATH nvidia to cuda

