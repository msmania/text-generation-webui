#!/bin/bash

MODEL_DIR=${MODEL/\//_}

[ -f "/app/${TUNNEL_KEY_NAME}" ] || \
  cp "/app/ssh-mount/${TUNNEL_KEY_NAME}" /app/ \
  && chmod 400 "/app/${TUNNEL_KEY_NAME}"

if [[ "${TUNNEL_REMOTE_PORT_RPC}" != "" ]]; then
  echo Connecting to ${TUNNEL_SERVER_RPC}...

  ssh -f -N -T \
    -o StrictHostKeyChecking=no \
    -R ${TUNNEL_REMOTE_PORT_RPC}:localhost:${OPENEDAI_PORT:-5001} \
    -i "/app/${TUNNEL_KEY_NAME}" \
    ${TUNNEL_SERVER_RPC}
  RET_SSH=$?

  if [ ${RET_SSH} -ne 0 ]; then
    echo Cannot establish the channel to ${TUNNEL_SERVER_RPC}
    tail -f /dev/null
  fi

  echo Established the channel to ${TUNNEL_SERVER_RPC}
fi

if [[ "${TUNNEL_REMOTE_PORT_STREAM}" != "" ]]; then
  echo Connecting to ${TUNNEL_SERVER_STREAM}...

  ssh -f -N -T \
    -o StrictHostKeyChecking=no \
    -R ${TUNNEL_REMOTE_PORT_STREAM}:localhost:${CONTAINER_API_STREAM_PORT:-5005} \
    -i "/app/${TUNNEL_KEY_NAME}" \
    ${TUNNEL_SERVER_STREAM}
  RET_SSH=$?

  if [ ${RET_SSH} -ne 0 ]; then
    echo Cannot establish the channel to ${TUNNEL_SERVER_STREAM}
    tail -f /dev/null
  fi

  echo Established the channel to ${TUNNEL_SERVER_STREAM}
fi

if [[ "${MODEL}" == "NULL" ]]; then
  tail -f /dev/null
fi

[ -f models/config.yaml ] || cp /app/models-config.yaml models/config.yaml

if [ ! -d "models/${MODEL_DIR}" ]; then
  python3 download-model.py "${MODEL}"
fi

python3 server.py --model ${MODEL_DIR} $@
