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
RUN apt-get install -y python3 python3-pip
RUN curl -fsSL https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.cargo/bin:$PATH"
RUN /root/.cargo/bin/uv venv
ENV PATH="/home/nonroot/devika/.venv/bin:/root/.cargo/bin:$PATH"

# copy devika python engine only
COPY requirements.txt /home/nonroot/devika/
RUN UV_HTTP_TIMEOUT=100000 /root/.cargo/bin/uv pip install -r requirements.txt 

RUN playwright install-deps chromium
RUN playwright install chromium

COPY src /home/nonroot/devika/src
COPY config.toml /home/nonroot/devika/
COPY sample.config.toml /home/nonroot/devika/
COPY devika.py /home/nonroot/devika/
RUN chown -R nonroot:nonroot /home/nonroot/devika

USER nonroot
WORKDIR /home/nonroot/devika
ENV PATH="/home/nonroot/devika/.venv/bin:/root/.cargo/bin:$PATH"
RUN mkdir /home/nonroot/devika/db

ENTRYPOINT [ "python3", "-m", "devika" ]
