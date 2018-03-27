FROM node:8.9.0-slim
MAINTAINER Harrison Powers, harrisonpowers@gmail.com

# Lock down npm version
RUN npm i -g npm@5.4.2
# Install pm2
RUN npm install pm2 -g
# Install misc deps (TODO: document these)
RUN apt update && apt install -y git wget curl vim nano libfontconfig poppler-utils \
    libcairo2-dev libjpeg-dev libgif-dev jq libfontconfig vim nano poppler-utils \
    libjpeg62-turbo-dev libpango1.0-dev build-essential g++ \
    catdoc graphviz pdftk libpython-dev python-pip \
    && apt-get clean && rm -rf /var/lib/apt/lists/*
# Install dumb-init
RUN wget https://github.com/Yelp/dumb-init/releases/download/v1.1.3/dumb-init_1.1.3_amd64 -O /usr/local/bin/dumb-init && chmod +x /usr/local/bin/dumb-init
# Install Chrome (TODO: separate container)
RUN apt update && apt-get install -y apt-transport-https ca-certificates curl gnupg hicolor-icon-theme libgl1-mesa-dri libgl1-mesa-glx libpulse0 libv4l-0 --no-install-recommends \
	&& curl -sSL https://dl.google.com/linux/linux_signing_key.pub | apt-key add - \
	&& echo "deb [arch=amd64] https://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google.list \
	&& apt-get update && apt-get install -y google-chrome-unstable --no-install-recommends \
  && apt-get clean && rm -rf /var/lib/apt/lists/* \
  && wget https://raw.githubusercontent.com/jfrazelle/dockerfiles/master/chrome/stable/local.conf -O /etc/fonts/local.conf \
  && groupadd -r chrome && useradd -r -g chrome -G audio,video chrome \
  && mkdir -p /home/chrome/Downloads && chown -R chrome:chrome /home/chrome \
  && echo 'nohup sh -c "google-chrome --headless --hide-scrollbars --remote-debugging-port=9222 --disable-gpu" > /dev/null &' > /home/chrome/start-chrome.sh

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
