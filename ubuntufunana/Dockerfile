# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.


ARG ROOT_CONTAINER=ubuntu:18.04

ARG BASE_CONTAINER=$ROOT_CONTAINER

ARG UBUNTURDPTAG=cuda10.1-cudnn7-ubuntu18.04
FROM ubunturdp:$UBUNTURDPTAG

SHELL ["/bin/bash", "--login", "-o", "pipefail", "-c"]

# --- User params

ARG NB_USER="funana"
ARG NB_UID="1000"
ARG NB_GID="100"

# --- installation

USER root

# 0. java
RUN apt-get update && \
    apt-get install -y openjdk-8-jdk && \
    apt-get install -y ant && \
    apt-get clean;
# Fix certificate issues
RUN apt-get update && \
    apt-get install ca-certificates-java && \
    apt-get clean && \
    update-ca-certificates -f;

# Setup JAVA_HOME -- useful for docker commandline
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64/
RUN export JAVA_HOME

# 1. conda

ARG conda_version="4.9.2"
ARG miniforge_patch_number="7"
ARG miniforge_arch="x86_64"

# Package Manager and Python implementation to use (https://github.com/conda-forge/miniforge)
# - conda only: either Miniforge3 to use Python or Miniforge-pypy3 to use PyPy
# - conda + mamba: either Mambaforge to use Python or Mambaforge-pypy3 to use PyPy
ARG miniforge_python="Mambaforge"

# Miniforge archive to install
ARG miniforge_version="${conda_version}-${miniforge_patch_number}"
# Miniforge installer
ARG miniforge_installer="${miniforge_python}-${miniforge_version}-Linux-${miniforge_arch}.sh"
# Miniforge checksum
ARG miniforge_checksum="5a827a62d98ba2217796a9dc7673380257ed7c161017565fba8ce785fb21a599"

# Install all OS dependencies for notebook server that starts but lacks all
# features (e.g., download as all possible file formats)
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get -q update \
 && apt-get install -yq --no-install-recommends \
    wget \
    ca-certificates \
    sudo \
    locales \
    fonts-liberation \
    run-one \
    git \
    cifs-utils \
    screen \
 && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen

# Configure environment
ENV CONDA_DIR=/opt/conda \
    SHELL=/bin/bash \
    NB_USER=$NB_USER \
    NB_UID=$NB_UID \
    NB_GID=$NB_GID \
    LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8 \
    HASH=\$1\$lh9hEEs.\$HPwSpeIq4JAz3i6Vtw0wI/

ENV PATH=$CONDA_DIR/bin:$PATH \
    HOME=/home/$NB_USER \
    CONDA_VERSION="${conda_version}" \
    MINIFORGE_VERSION="${miniforge_version}"

# 2. fix direcotories

# Copy a script that we will use to correct permissions after running certain commands
COPY fix-permissions /usr/local/bin/fix-permissions
RUN chmod a+rx /usr/local/bin/fix-permissions

# 3. Console colors
# Enable prompt color in the skeleton .bashrc before creating the default NB_USER
# hadolint ignore=SC2016
RUN sed -i 's/^#force_color_prompt=yes/force_color_prompt=yes/' /etc/skel/.bashrc && \
   # Add call to conda init script see https://stackoverflow.com/a/58081608/4413446
   echo 'eval "$(command conda shell.bash hook 2> /dev/null)"' >> /etc/skel/.bashrc 


# Create NB_USER with name jovyan user with UID=1000 and in the 'users' group
# and make sure these dirs are writable by the `users` group.
# mkdir -p $HOME && cp -rT /etc/skel $HOME &&\
#RUN chmod 664 /var/log/tallylog && echo "auth requisite pam_deny.so" >> /etc/pam.d/su && \
#    sed -i.bak -e 's/^%admin/#%admin/' /etc/sudoers && \
#    sed -i.bak -e 's/^%sudo/#%sudo/' /etc/sudoers && \
RUN sed -i.bak -e '/^%sudo/a '"$NB_USER"' ALL=(ALL) NOPASSWD: ALL' /etc/sudoers && cat /etc/sudoers && chmod 664 /var/log/tallylog && \
    useradd -m -g $NB_GID -u $NB_UID $NB_USER && \ 
    sudo usermod -aG sudo $NB_USER && \ 
    echo "$NB_USER:$HASH" | /usr/sbin/chpasswd -e && usermod -aG $NB_GID $NB_USER && \
    mkdir -p $CONDA_DIR && mkdir -p $CONDA_DIR/pkgs && \
    chown $NB_USER:$NB_GID $CONDA_DIR && \
    chmod g+w /etc/passwd /opt && \
    fix-permissions $HOME && \
    fix-permissions $CONDA_DIR &&\
    openssl rand -out $HOME/.rnd -writerand $HOME/.rnd && chmod 600 $HOME/.rnd

RUN echo "******************************" && ls -lart /home/*


ARG PYTHON_VERSION=default

# Setup work directory for backward-compatibility
RUN mkdir -p "/home/$NB_USER/work" && \
    fix-permissions "/home/$NB_USER"

# Creates skeleton of funana-users with default files
ADD etc /etc
ADD bin /usr/bin


USER $NB_UID

# Install conda as jovyan and check the sha256 sum provided on the download site
WORKDIR /tmp

# Prerequisites installation: conda, mamba, pip, tini
RUN wget --quiet "https://github.com/conda-forge/miniforge/releases/download/${miniforge_version}/${miniforge_installer}" && \
    echo "${miniforge_checksum} *${miniforge_installer}" | sha256sum --check && \
    /bin/bash "${miniforge_installer}" -f -b -p $CONDA_DIR && \
    rm "${miniforge_installer}" && \
    # Conda configuration see https://conda.io/projects/conda/en/latest/configuration.html
    echo "conda ${CONDA_VERSION}" >> $CONDA_DIR/conda-meta/pinned && \
    conda config --system --set auto_update_conda false && \
    conda config --system --set show_channel_urls true && \
    if [ ! $PYTHON_VERSION = 'default' ]; then conda install --yes python=$PYTHON_VERSION; fi && \
    conda list python | grep '^python ' | tr -s ' ' | cut -d '.' -f 1,2 | sed 's/$/.*/' >> $CONDA_DIR/conda-meta/pinned && \
    conda install --quiet --yes \
    "conda=${CONDA_VERSION}" \
    'pip' \
    'tini=0.18.0' && \
    conda update --all --quiet --yes && \
    conda list tini | grep tini | tr -s ' ' | cut -d ' ' -f 1,2 >> $CONDA_DIR/conda-meta/pinned && \
    conda clean --all -f -y && \
    rm -rf /home/$NB_USER/.cache/yarn && \
    fix-permissions $CONDA_DIR && \
   fix-permissions /home/$NB_USER

# # Ilastik installation
# # As described in ilastik official repo in 2019 select ilastik from ilastik_binary=<ilastik-archive> as found on files.ilastik.org, e.g. ilastik-1.3.2b3-Linux.tar.bz2
# ARG ILASTIK_BINARY=ilastik-1.3.2b3-Linux.tar.bz2

# ADD http://files.ilastik.org/$ILASTIK_BINARY /tmp/

# RUN echo '-------------------' && id 

# RUN sudo chmod 666 $ILASTIK_BINARY && sudo mkdir /opt/ilastik-release && \
#     sudo chown -R $NB_UID:$NB_GID /opt/ilastik-release && \
#     tar xjvf $ILASTIK_BINARY -C /opt/ilastik-release --strip-components=1 && \
#     sudo rm $ILASTIK_BINARY && \
#     fix-permissions /opt/ilastik-release

# # Fiji installation
# # Similarly, define the release version from: https://downloads.imagej.net/fiji/archive/ e.g. 20201104-1356
# ARG FIJI_BINARY=20201104-1356

# ADD https://downloads.imagej.net/fiji/archive/$FIJI_BINARY/fiji-linux64.tar.gz /tmp/


# RUN sudo chmod 666 fiji-linux64.tar.gz && sudo mkdir /opt/fiji && \
#     sudo chown -R $NB_UID:$NB_GID /opt/fiji && \
#     tar zxvf fiji-linux64.tar.gz -C /opt/fiji && \
#     sudo rm fiji-linux64.tar.gz && \
#     fix-permissions /opt/fiji

# # Noise2Void installation
ENV N2V_PATH=/opt/quick-n2v
ADD https://github.com/aiporre/quick-n2v/archive/refs/tags/v0.2.tar.gz /tmp/quickn2v.tar.gz

RUN sudo chmod 666 quickn2v.tar.gz && sudo mkdir $N2V_PATH && \
    sudo chown -R $NB_UID:$NB_GID $N2V_PATH && \
    tar zxvf quickn2v.tar.gz --directory $N2V_PATH  --strip 1 && \
    sudo rm quickn2v.tar.gz && \
    conda create -n n2v pip python==3.7

RUN echo "-----------------" && ls -lart $N2V_PATH

SHELL ["conda", "run", "--no-capture-output", "-n", "n2v", "/bin/bash", "-o", "pipefail", "-c"]

RUN install_tf_n2v.sh && \ 
    pip install -r $N2V_PATH/requirements.txt && \
    fix-permissions /opt/quick-n2v 

USER root

RUN echo "# Noise2void alliases " >> /etc/skel/.bashrc && \
    echo "export N2V_PATH=\"$N2V_PATH\"" >> /etc/skel/.bashrc && \
    echo "alias n2vimages=\"python \$N2V_PATH/onimages.py\"" >> /etc/skel/.bashrc && \  
    echo "alias n2vvideo=\"python \$N2V_PATH/onvideo.py\"" >> /etc/skel/.bashrc && \  
    echo "alias n2vrun=\"python \$N2V_PATH/onimagestunning.py\"" >> /etc/skel/.bashrc


# SHELL ["/bin/bash", "-o", "pipefail", "-c"]


# stardist installation

USER $NB_UID

ENV STARDIST_PATH=/opt/stardistcluster
RUN sudo mkdir -p $STARDIST_PATH && sudo chown -R $NB_UID:$NB_GID $STARDIST_PATH && \
    git clone --depth=1 --branch=master https://github.com/aiporre/stardistcluster.git $STARDIST_PATH && \
    rm -rf $STARDIST_PATH/.git && fix-permissions $STARDIST_PATH && \
    conda env create -f $STARDIST_PATH/installation/environment_gpu.yaml

RUN echo "-----------------" && ls $STARDIST_PATH
# to activate conda stardist 
SHELL ["conda", "run", "--no-capture-output", "-n", "stardist-gpu", "/bin/bash", "-o", "pipefail", "-c"]

RUN install_tf_stardist.sh && pip install $STARDIST_PATH/installation/ 


# # Cell pose installlation
# ARG CELLPOSE_VERSION=v0.6.1
# ARG MXNET_VERSION=mxnet-cu112
# ARG CELLPOSE_CUDATOOLKIT=11.1
# ARG CELLPOSE_PATH=/opt/cellpose

# ENV CELLPOSE_PATH=$CELLPOSE_PATH

# RUN sudo mkdir -p $CELLPOSE_PATH && sudo chown -R $NB_UID:$NB_GID $CELLPOSE_PATH && \
#     git clone https://github.com/MouseLand/cellpose.git $CELLPOSE_PATH 

# WORKDIR $CELLPOSE_PATH

# RUN git reset --hard $CELLPOSE_VERSION && \
#     rm -rf $CELLPOSE_PATH/.git && fix-permissions $CELLPOSE_PATH && \
#     conda env create -f $CELLPOSE_PATH/environment.yml

# RUN echo "-----------------" && ls $CELLPOSE_PATH
# # to activate conda stardist 
# SHELL ["conda", "run", "--no-capture-output", "-n", "cellpose", "/bin/bash", "-o", "pipefail", "-c"]

# RUN pip install cellpose --upgrade && conda install -y jupyter && \
#     pip install matplotlib scikit-image && pip install cellpose[gui] && \
#     pip uninstall --yes torch && \
#     conda install -y pytorch cudatoolkit=$CELLPOSE_CUDATOOLKIT -c pytorch -c nvidia && \
#     pip install --no-deps cellpose --upgrade && \
#     pip install $MXNET_VERSION

# # Elektronn installlation
# ENV ELEKTRONN_PATH=/opt/elektronn3

# RUN sudo mkdir -p $ELEKTRONN_PATH && sudo chown -R $NB_UID:$NB_GID $ELEKTRONN_PATH && \
#     git clone https://github.com/ELEKTRONN/elektronn3 $ELEKTRONN_PATH && \
#     rm -rf $ELEKTRONN_PATH/.git && fix-permissions $ELEKTRONN_PATH && \
#     conda env create -f $ELEKTRONN_PATH/environment.yml

# RUN echo "-----------------" && ls $ELEKTRONN_PATH
# # to activate conda stardist 
# SHELL ["conda", "run", "--no-capture-output", "-n", "elektronn3", "/bin/bash", "-o", "pipefail", "-c"]

# RUN pip install -e $ELEKTRONN_PATH

# # Deepstorm installation

# ARG DEEPSTORM_VERSION=1.12.2
# ARG DEEPSTORM_PATH=/opt/deepstorm

# ENV DEEPSTORM_PATH=$DEEPSTORM_PATH

# RUN sudo mkdir -p $DEEPSTORM_PATH && sudo chown -R $NB_UID:$NB_GID $DEEPSTORM_PATH && \
#     git clone https://github.com/HenriquesLab/ZeroCostDL4Mic.git $DEEPSTORM_PATH 

# WORKDIR $DEEPSTORM_PATH

# #RUN git reset --hard $DEEPSTORM_VERSION && \
# RUN rm -rf $DEEPSTORM_PATH/.git && fix-permissions $DEEPSTORM_PATH && \
#     conda create --y -n deepstorm python=3.7

# RUN echo "-----------------" && ls $DEEPSTORM_PATH
# to activate conda stardist 
# SHELL ["conda", "run", "--no-capture-output", "-n", "deepstorm", "/bin/bash", "-o", "pipefail", "-c"]

# RUN pip install -r $DEEPSTORM_PATH/requirements_files/DeepSTORM_requirements_simple.txt && \
#     pip install tensorflow==2.5.0

# Turn off conda environment activation
SHELL ["/bin/bash", "-o", "pipefail", "-c"]


# Setting .bashrc for all users

USER root

RUN echo "# Default configurations funana user" >> /etc/skel/.bashrc && \
    echo "export PATH=\"$PATH:\$PATH\"" >> /etc/skel/.bashrc && \
    echo "export LD_LIBRARY_PATH=\"$LD_LIBRARY_PATH:\$LD_LIBRARY_PATH\"" >> /etc/skel/.bashrc && \
    echo "export NVIDIA_VISIBLE_DEVICES=\"$NVIDIA_VISIBLE_DEVICES" >> /etc/skel/.bashrc  && \
    echo "export NCCL_VERSION=\"$NCCL_VERSION" >> /etc/skel/.bashrc && \
    echo "export LIBRARY_PATH=\"$LIBRARY_PATH:\$LIBRARY_PATH\"" >> /etc/skel/.bashrc && \
    echo "export CUDA_VERSION=\"$CUDA_VERSION\"" >> /etc/skel/.bashrc && \
    echo "export JAVA_HOME=\"$JAVA_HOME\"" >> /etc/skel/.bashrc

COPY images /opt/sds/images

WORKDIR /etc/xrdp  
USER $NB_UID



#VOLUME ["/etc/ssh"]
#EXPOSE 3389 22 9001
ENTRYPOINT ["/usr/bin/docker-entrypoint-funana.sh"]
CMD ["sudo", "supervisord"]
USER $NB_UID

