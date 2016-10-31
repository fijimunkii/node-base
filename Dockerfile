FROM node:5.5.0
MAINTAINER Harrison Powers, harrisonpowers@gmail.com

ARG BUILD_DATE
ARG VCS_REF
ARG VCS_URL

LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url=$VCS_URL

RUN apt update && apt install -y libfontconfig vim nano poppler-utils \
    && rm -rf /var/lib/apt/lists/*

RUN npm install pm2 -g

RUN mkdir -p /usr/src/app/server && \
    mkdir -p /usr/src/app/client;

ADD server/package.json /usr/src/app/server/package.json
RUN cd /usr/src/app/server && npm install

ADD client/package.json /usr/src/app/client/package.json
ADD client/bower.json /usr/src/app/client/bower.json
RUN cd /usr/src/app/client && npm install && npm run postinstall

ADD https://github.com/Yelp/dumb-init/releases/download/v1.1.3/dumb-init_1.1.3_amd64 /usr/local/bin/dumb-init
RUN chmod +x /usr/local/bin/dumb-init

WORKDIR /usr/src/app

ENTRYPOINT ["dumb-init"]

CMD ["bash"]
