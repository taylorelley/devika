FROM debian:12

# setting
WORKDIR /home/nonroot/devika
RUN groupadd -r nonroot && useradd -r -g nonroot -d /home/nonroot/devika -s /bin/bash nonroot

ENV PYTHONUNBUFFERED 1
ENV PYTHONDONTWRITEBYTECODE 1

# setting up python3 & other requirements
RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y build-essential software-properties-common curl sudo wget git ca-certificates
RUN apt-get install -y python3 python3-pip pkg-config libcairo2-dev cmake

# Download the latest installer
ADD https://astral.sh/uv/install.sh /uv-installer.sh

# Run the installer then remove it
RUN sh /uv-installer.sh && rm /uv-installer.sh

# Ensure the installed binary is on the `PATH`
ENV PATH="/root/.local/bin/:$PATH"

RUN uv venv

# copy devika python engine only
COPY requirements.txt /home/nonroot/devika/
RUN uv pip install -r requirements.txt

#RUN python3 -m playwright install-deps chromium
#RUN python3 -m playwright install chromium
RUN /home/nonroot/devika/.venv/bin/python3 -m playwright install-deps chromium
RUN /home/nonroot/devika/.venv/bin/python3 -m playwright install chromium


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
