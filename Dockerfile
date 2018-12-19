FROM python:3.6.6

ENV SUPERCRONIC_URL=https://github.com/aptible/supercronic/releases/download/v0.1.6/supercronic-linux-amd64 \
    SUPERCRONIC=supercronic-linux-amd64 \
    SUPERCRONIC_SHA1SUM=c3b78d342e5413ad39092fd3cfc083a85f5e2b75

RUN apt-get update && apt-get install -y \
    build-essential \
    ca-certificates \
    curl \
    gcc \
    git \
    gzip \
    make \
    netcat \
    ssh \
    tar \
    && curl -fsSLO "$SUPERCRONIC_URL" \
    && echo "${SUPERCRONIC_SHA1SUM}  ${SUPERCRONIC}" | sha1sum -c - \
    && chmod +x "$SUPERCRONIC" \
    && mv "$SUPERCRONIC" "/usr/local/bin/${SUPERCRONIC}" \
    && ln -s "/usr/local/bin/${SUPERCRONIC}" /usr/local/bin/supercronic

ADD . /code

WORKDIR /code

RUN pip install -r requirements.txt

ENTRYPOINT ["supercronic"]

CMD ["crontab"]
