#!/bin/bash
  

CUDA_FOR_TF_2p5="11.2.0"

if [ "$CUDA_VERSION" = "$CUDA_FOR_TF_2p5" ]; then
    echo "Installing tensorflow-gpu 2.5.0"
    pip install tensorflow-gpu==2.5.0
else
    echo "Installing tensorflow-gpu 2.4.0"
    pip install tensorflow-gpu==2.4.0
fi

