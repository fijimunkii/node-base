FROM node:8.9.0
MAINTAINER Harrison Powers, harrisonpowers@gmail.com

# Lock down NPM to known stable version
RUN npm i -g npm@5.4.2

RUN apt update && apt install -y jq libfontconfig vim nano poppler-utils \
    libcairo2-dev libjpeg62-turbo-dev libpango1.0-dev libgif-dev build-essential g++ \
    catdoc graphviz pdftk \
    libpython-dev python-pip \
    && rm -rf /var/lib/apt/lists/* \
    && pip install awscli

RUN mkdir -p /usr/src/app/server && \
    mkdir -p /usr/src/app/client;

ADD server/package.json /usr/src/app/server/package.json
RUN cd /usr/src/app/server && npm install

ADD client/package.json /usr/src/app/client/package.json
ADD client/bower.json /usr/src/app/client/bower.json
RUN cd /usr/src/app/client && npm install && npm run postinstall

ADD https://github.com/Yelp/dumb-init/releases/download/v1.1.3/dumb-init_1.1.3_amd64 /usr/local/bin/dumb-init
RUN chmod +x /usr/local/bin/dumb-init

# Add docker user (so we dont run as root)
RUN groupadd -r docker && useradd -r -g docker docker \
    && usermod -d /usr/src/app docker \
    && chown -R docker:docker /usr/src/app \
    && printf "docker\ndocker\n" | passwd docker

# Install pm2 as docker user
RUN su -c "npm i -g pm2" -m docker

WORKDIR /usr/src/app

ENTRYPOINT ["dumb-init"]

CMD ["bash"]
