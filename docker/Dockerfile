FROM nvidia/cuda:12.2.0-devel-ubuntu22.04
ARG TORCH_CUDA_ARCH_LIST="${TORCH_CUDA_ARCH_LIST:-3.5;5.0;6.0;6.1;7.0;7.5;8.0;8.6+PTX}"

LABEL maintainer="Toshihito Kikuchi <toshi@c0d3r.org>"
LABEL description="Docker image for Text Generation RPC"

ENV MODEL=""
ENV TUNNEL_SERVER=""
ENV TUNNEL_REMOTE_PORT=""
ENV TUNNEL_KEY_NAME=""
ENV CLI_ARGS=""

VOLUME /app/ssh-mount

RUN mkdir /app
WORKDIR /app
COPY . /app/

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked,rw apt-get update && \
    apt-get install --no-install-recommends -y python3-dev libportaudio2 \
    libasound-dev git python3 python3-pip make g++ ffmpeg ssh && \
    rm -rf /var/lib/apt/lists/*

RUN --mount=type=cache,target=/root/.cache/pip,rw pip3 install virtualenv

# Create virtualenv
RUN virtualenv /app/venv
RUN --mount=type=cache,target=/root/.cache/pip,rw \
    . /app/venv/bin/activate && \
    pip3 install --upgrade pip setuptools wheel && \
    pip3 install torch==2.1.0 torchvision torchaudio sentence_transformers && \
    pip3 install xformers

# Install main requirements
RUN --mount=type=cache,target=/root/.cache/pip,rw \
    . /app/venv/bin/activate && \
    pip3 install -r requirements.txt

RUN cp /app/venv/lib/python3.10/site-packages/bitsandbytes/libbitsandbytes_cuda122.so \
    /app/venv/lib/python3.10/site-packages/bitsandbytes/libbitsandbytes_cpu.so

# Install extension requirements
RUN --mount=type=cache,target=/root/.cache/pip,rw \
    . /app/venv/bin/activate && \
    for ext in /app/extensions/*/requirements.txt; do \
    cd "$(dirname "$ext")"; \
    pip3 install -r requirements.txt; \
    done

EXPOSE ${CONTAINER_API_PORT:-5000} \
    ${CONTAINER_API_STREAM_PORT:-5005} \
    ${OPENEDAI_PORT}
CMD . /app/venv/bin/activate && \
    ./start_rpc_server.sh \
    --extension openai \
    --listen \
    --trust-remote-code \
    --load-in-4bit \
    ${CLI_ARGS}
