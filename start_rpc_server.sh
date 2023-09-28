#!/bin/bash

MODEL=$1
MODEL_DIR=${MODEL/\//_}

if [ ! -d "models/${MODEL_DIR}" ]; then
  python3 download-model.py "${MODEL}"
fi

python3 server.py \
  --model ${MODEL_DIR} \
  ${@:2}
