FROM debian:12

# setting up os env
USER root
WORKDIR /home/nonroot/devika
RUN groupadd -r nonroot && useradd -r -g nonroot -d /home/nonroot/devika -s /bin/bash nonroot

ENV PYTHONUNBUFFERED 1
ENV PYTHONDONTWRITEBYTECODE 1

# setting up python3
RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y build-essential software-properties-common curl sudo wget git
RUN apt-get install -y python3 python3-pip pkg-config libcairo2-dev cmake

# install uv using official recommended method
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/
RUN uv venv
ENV PATH="/home/nonroot/devika/.venv/bin:$PATH"

# copy devika python engine only
COPY requirements.txt /home/nonroot/devika/
RUN UV_HTTP_TIMEOUT=100000 uv pip install -r requirements.txt

RUN /home/nonroot/devika/.venv/bin/python3 -m playwright install-deps chromium
RUN /home/nonroot/devika/.venv/bin/python3 -m playwright install chromium

COPY src /home/nonroot/devika/src
COPY config.toml /home/nonroot/devika/
COPY sample.config.toml /home/nonroot/devika/
COPY devika.py /home/nonroot/devika/
RUN chown -R nonroot:nonroot /home/nonroot/devika

USER nonroot
WORKDIR /home/nonroot/devika
ENV PATH="/home/nonroot/devika/.venv/bin:$PATH"
RUN mkdir /home/nonroot/devika/db

ENTRYPOINT [ "python3", "-m", "devika" ]
