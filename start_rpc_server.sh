#!/bin/bash

MODEL_DIR=${MODEL/\//_}

[ -f "/app/${TUNNEL_KEY_NAME}" ] || \
  cp "/app/ssh-mount/${TUNNEL_KEY_NAME}" /app/ \
  && chmod 400 "/app/${TUNNEL_KEY_NAME}"

[ -f "/app/${TUNNEL_SERVER_PUBKEY}" ] || \
  cp "/app/ssh-mount/${TUNNEL_SERVER_PUBKEY}" /app/ \
  && chmod 400 "/app/${TUNNEL_SERVER_PUBKEY}"

if [[ "${TUNNEL_SERVER_ENDPOINT}" != "" ]]; then
  echo Connecting to ${TUNNEL_SERVER_ENDPOINT}...
  /app/kinesisd -c \
    "/app/${TUNNEL_KEY_NAME}" \
    "/app/${TUNNEL_SERVER_PUBKEY}" \
    ${TUNNEL_SERVER_ENDPOINT} \
    ${TUNNEL_LOCAL_ENDPOINT} &
fi

if [[ "${MODEL}" == "" ]]; then
  tail -f /dev/null
fi

[ -f models/config.yaml ] || cp /app/models-config.yaml models/config.yaml

if [ ! -d "models/${MODEL_DIR}" ]; then
  python3 download-model.py "${MODEL}"
fi

python3 server.py --model ${MODEL_DIR} $@
