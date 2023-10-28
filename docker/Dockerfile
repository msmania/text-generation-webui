FROM nvidia/cuda:12.1.0-runtime-ubuntu22.04

LABEL maintainer="Toshihito Kikuchi <toshi@c0d3r.org>"
LABEL description="Docker image for Text Generation RPC"

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked,rw apt-get update && \
    apt-get install --no-install-recommends -y python3-dev libportaudio2 libasound-dev git python3 python3-pip make g++ ffmpeg && \
    rm -rf /var/lib/apt/lists/*

RUN --mount=type=cache,target=/root/.cache/pip,rw pip3 install virtualenv

RUN mkdir /app

WORKDIR /app

# Create virtualenv
RUN virtualenv /app/venv
RUN --mount=type=cache,target=/root/.cache/pip,rw \
    . /app/venv/bin/activate && \
    pip3 install --upgrade pip setuptools wheel ninja && \
    pip3 install torch --index-url https://download.pytorch.org/whl/cu121 && \
    pip3 install torchvision torchaudio sentence_transformers xformers

# Install main requirements
COPY requirements.txt /app/requirements.txt
RUN --mount=type=cache,target=/root/.cache/pip,rw \
    . /app/venv/bin/activate && \
    pip3 install -r requirements.txt

COPY . /app/

COPY models/config.yaml /app/models-config.yaml
RUN rm -rf /app/models

RUN cp /app/venv/lib/python3.10/site-packages/bitsandbytes/libbitsandbytes_cuda121.so /app/venv/lib/python3.10/site-packages/bitsandbytes/libbitsandbytes_cpu.so

# Install extension requirements
RUN --mount=type=cache,target=/root/.cache/pip,rw \
    . /app/venv/bin/activate && \
    for ext in /app/extensions/*/requirements.txt; do \
    cd "$(dirname "$ext")"; \
    pip3 install -r requirements.txt; \
    done

ENV CLI_ARGS=""

EXPOSE ${CONTAINER_PORT:-7860} ${CONTAINER_API_PORT:-5000} ${CONTAINER_API_STREAM_PORT:-5005}
CMD . /app/venv/bin/activate && \
    ./start_rpc_server.sh \
    --api \
    --api-blocking-port ${CONTAINER_API_PORT:-5000} \
    --api-streaming-port ${CONTAINER_API_STREAM_PORT:-5005} \
    --listen \
    --trust-remote-code \
    --load-in-4bit \
    ${CLI_ARGS}
