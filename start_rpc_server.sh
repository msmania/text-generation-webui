#!/bin/bash

MODEL_DIR=${MODEL/\//_}

if [[ "${MODEL}" == "" ]]; then
  tail -f /dev/null
fi

[ -f models/config.yaml ] || cp /app/models-config.yaml models/config.yaml

if [ ! -d "models/${MODEL_DIR}" ]; then
  python3 download-model.py "${MODEL}"
fi

python3 server.py --model ${MODEL_DIR} $@
