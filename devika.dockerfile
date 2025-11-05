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

# Create venv and install dependencies using explicit uv path
RUN /root/.local/bin/uv venv

# copy devika python engine only
COPY requirements.txt /home/nonroot/devika/
RUN /root/.local/bin/uv pip install -r requirements.txt

# Install Playwright with explicit venv python path
RUN /home/nonroot/devika/.venv/bin/python3 -m playwright install-deps chromium
RUN /home/nonroot/devika/.venv/bin/python3 -m playwright install chromium

COPY src /home/nonroot/devika/src
COPY config.toml /home/nonroot/devika/
COPY sample.config.toml /home/nonroot/devika/
COPY devika.py /home/nonroot/devika/
RUN chown -R nonroot:nonroot /home/nonroot/devika

USER nonroot
ENV PATH="/home/nonroot/devika/.venv/bin:$PATH"
RUN mkdir /home/nonroot/devika/db

ENTRYPOINT [ "/home/nonroot/devika/.venv/bin/python3", "-m", "devika" ]
