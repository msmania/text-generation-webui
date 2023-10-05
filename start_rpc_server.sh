#!/bin/bash

MODEL_DIR=${MODEL/\//_}

if [[ "${TUNNEL_KEY_NAME}" != "" ]]; then
  echo Connecting to ${TUNNEL_SERVER}...

  [ -f "/app/${TUNNEL_KEY_NAME}" ] || \
    cp "/app/ssh-mount/${TUNNEL_KEY_NAME}" /app/ \
    && chmod 400 "/app/${TUNNEL_KEY_NAME}"

  ssh -f -N -T \
    -o StrictHostKeyChecking=no \
    -R ${TUNNEL_REMOTE_PORT}:localhost:${OPENEDAI_PORT} \
    -i "/app/${TUNNEL_KEY_NAME}" \
    ${TUNNEL_SERVER}
  RET_SSH=$?

  if [ ${RET_SSH} -ne 0 ]; then
    echo Cannot establish the channel to ${TUNNEL_SERVER}
    tail -f /dev/null
  fi

  echo Established the channel to ${TUNNEL_SERVER}
fi

if [[ "${MODEL}" == "NULL" ]]; then
  tail -f /dev/null
fi

[ -f models/config.yaml ] || cp /app/models-config.yaml models/config.yaml

if [ ! -d "models/${MODEL_DIR}" ]; then
  python3 download-model.py "${MODEL}"
fi

python3 server.py --model ${MODEL_DIR} $@
