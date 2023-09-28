FROM nvidia/cuda:12.2.0-devel-ubuntu22.04
ARG TORCH_CUDA_ARCH_LIST="${TORCH_CUDA_ARCH_LIST:-3.5;5.0;6.0;6.1;7.0;7.5;8.0;8.6+PTX}"

LABEL maintainer="Toshihito Kikuchi <toshi@c0d3r.org>"
LABEL description="Docker image for Text Generation RPC"

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked,rw apt-get update && \
    apt-get install --no-install-recommends -y python3-dev libportaudio2 libasound-dev git python3 python3-pip make g++ ffmpeg && \
    rm -rf /var/lib/apt/lists/*

RUN --mount=type=cache,target=/root/.cache/pip,rw pip3 install virtualenv
RUN mkdir /app

WORKDIR /app

ARG WEBUI_VERSION
RUN test -n "${WEBUI_VERSION}" && git reset --hard ${WEBUI_VERSION} || \
    echo "Using provided webui source"

# Create virtualenv
RUN virtualenv /app/venv
RUN --mount=type=cache,target=/root/.cache/pip,rw \
    . /app/venv/bin/activate && \
    pip3 install --upgrade pip setuptools wheel && \
    pip3 install torch torchvision torchaudio sentence_transformers xformers

# Install main requirements
COPY requirements.txt /app/requirements.txt
RUN --mount=type=cache,target=/root/.cache/pip,rw \
    . /app/venv/bin/activate && \
    pip3 install -r requirements.txt

COPY . /app/

RUN cp /app/venv/lib/python3.10/site-packages/bitsandbytes/libbitsandbytes_cuda122.so \
    /app/venv/lib/python3.10/site-packages/bitsandbytes/libbitsandbytes_cpu.so

# Install extension requirements
RUN --mount=type=cache,target=/root/.cache/pip,rw \
    . /app/venv/bin/activate && \
    for ext in /app/extensions/*/requirements.txt; do \
    cd "$(dirname "$ext")"; \
    pip3 install -r requirements.txt; \
    done

ENV MODEL=""
ENV CLI_ARGS=""

EXPOSE ${CONTAINER_API_PORT:-5000} \
    ${CONTAINER_API_STREAM_PORT:-5005} \
    ${OPENEDAI_PORT}
CMD . /app/venv/bin/activate && \
    ./start_rpc_server.sh \
    ${MODEL} \
    --extension openai \
    --listen \
    --trust-remote-code \
    --load-in-4bit \
    ${CLI_ARGS}
