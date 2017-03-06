FROM node:6.9.2
MAINTAINER Harrison Powers, harrisonpowers@gmail.com

RUN apt update && apt install -y libfontconfig vim nano poppler-utils \
    libcairo2-dev libjpeg62-turbo-dev libpango1.0-dev libgif-dev build-essential g++ \
    catdoc graphviz \
    && rm -rf /var/lib/apt/lists/*

RUN npm install pm2 node-gyp -g

RUN mkdir -p /usr/src/app/server && \
    mkdir -p /usr/src/app/client;

ADD server/package.json /usr/src/app/server/package.json
RUN cd /usr/src/app/server && npm install

RUN cd /usr/src/app/server/node_modules/canvas && node-gyp rebuild

ADD client/package.json /usr/src/app/client/package.json
ADD client/bower.json /usr/src/app/client/bower.json
RUN cd /usr/src/app/client && npm install && npm run postinstall

ADD https://github.com/Yelp/dumb-init/releases/download/v1.1.3/dumb-init_1.1.3_amd64 /usr/local/bin/dumb-init
RUN chmod +x /usr/local/bin/dumb-init

WORKDIR /usr/src/app

ENTRYPOINT ["dumb-init"]

CMD ["bash"]
