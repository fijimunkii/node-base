FROM node:8.9.0
MAINTAINER Harrison Powers, harrisonpowers@gmail.com

RUN npm i -g npm@5.4.2

# Install go
ADD https://storage.googleapis.com/golang/go1.9.2.linux-amd64.tar.gz /usr/local/go.tar.gz
RUN tar -xvf /usr/local/go.tar.gz && chmod +x /usr/local/go

# Install various deps
RUN apt update && apt install -y jq libfontconfig vim nano poppler-utils \
    libcairo2-dev libjpeg62-turbo-dev libpango1.0-dev libgif-dev build-essential g++ \
    catdoc graphviz pdftk \
    libpython-dev python-pip \
    && rm -rf /var/lib/apt/lists/*

RUN pip install awscli

RUN npm install pm2 -g

# Preinstall node modules
RUN mkdir -p /usr/src/app/server && \
    mkdir -p /usr/src/app/client;

ADD server/package.json /usr/src/app/server/package.json
RUN cd /usr/src/app/server && npm install

ADD client/package.json /usr/src/app/client/package.json
ADD client/bower.json /usr/src/app/client/bower.json
RUN cd /usr/src/app/client && npm install && npm run postinstall

# Clean up node_modules
RUN go get github.com/tj/node-prune/cmd/node-prune
RUN node-prune /usr/src/app/client
RUN node-prune /usr/src/app/server

# Install dumb-init
ADD https://github.com/Yelp/dumb-init/releases/download/v1.1.3/dumb-init_1.1.3_amd64 /usr/local/bin/dumb-init
RUN chmod +x /usr/local/bin/dumb-init

WORKDIR /usr/src/app

ENTRYPOINT ["dumb-init"]

CMD ["bash"]
