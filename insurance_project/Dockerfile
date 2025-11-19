# Dockerfile - plain development container (no entrypoint, no start script)
FROM python:3.11-slim

# set a non-root user (optional but recommended)
ARG USER=dev
ARG UID=1000
ARG GID=1000

# system deps required for common Python packages and DB client
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
    build-essential \
    gcc \
    libpq-dev \
    git \
    curl \
    vim \
    locales \
    ca-certificates \
    procps \
 && rm -rf /var/lib/apt/lists/*

# create non-root user
RUN groupadd -g ${GID} ${USER} || true \
 && useradd -m -u ${UID} -g ${GID} -s /bin/bash ${USER} || true

# create app dir and set permissions
ENV APP_HOME=/app
RUN mkdir -p ${APP_HOME} && chown ${USER}:${USER} ${APP_HOME}
WORKDIR ${APP_HOME}

# copy only requirements file at build time for layer caching (if you have one)
# If you don't have requirements.txt yet, it's fine: you'd mount project and pip install inside container.
COPY requirements.txt ./requirements.txt
RUN pip install -r /app/requirements.txt

# install pip tools
RUN python -m pip install --upgrade pip setuptools wheel

# default command: give you a shell when container runs
# No entrypoint, no scripts — user will shell in and run commands manually
CMD ["/bin/bash"]
