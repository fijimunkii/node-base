# pull from checksum to ensure it never changes
# docker image ls --digests --format '{{.Digest}}'
# node:10.15.0-stretch
FROM node@sha256:cdca9751c481ae77f2f57bf8a7337c378a144af45310f7d2711d265f5ac9ef15

MAINTAINER Harrison Powers, harrisonpowers@gmail.com

RUN apt update && apt install -y jq libfontconfig vim nano poppler-utils net-tools \
    libcairo2-dev libjpeg62-turbo-dev libpango1.0-dev libgif-dev build-essential g++ \
    catdoc graphviz pdftk \
    libpython-dev python-pip \
    haxe \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir ~/haxelib && haxelib setup ~/haxelib

RUN pip install awscli

RUN npm install pm2 -g

RUN mkdir -p /usr/src/app/server && \
    mkdir -p /usr/src/app/client;

ADD server/package.json /usr/src/app/server/package.json
RUN cd /usr/src/app/server && npm install

ADD client/package.json /usr/src/app/client/package.json
ADD client/bower.json /usr/src/app/client/bower.json
RUN cd /usr/src/app/client && npm install && npm run postinstall

RUN wget -O /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.0/dumb-init_1.2.0_amd64
RUN chmod +x /usr/local/bin/dumb-init

WORKDIR /usr/src/app

ENTRYPOINT ["dumb-init"]

CMD ["bash"]
