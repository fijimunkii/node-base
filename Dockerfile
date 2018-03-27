FROM node:8.9.0-slim
MAINTAINER Harrison Powers, harrisonpowers@gmail.com

# Install Deps
RUN npm i -g npm@5.4.2 \
  && npm i -g pm2 \
  && apt update && apt install -y git wget curl vim nano libfontconfig poppler-utils \
    libcairo2-dev libjpeg-dev libgif-dev jq libfontconfig vim nano poppler-utils \
    libjpeg62-turbo-dev libpango1.0-dev build-essential g++ \
    catdoc graphviz pdftk libpython-dev python-pip \
  && wget https://github.com/Yelp/dumb-init/releases/download/v1.1.3/dumb-init_1.1.3_amd64 -O /usr/local/bin/dumb-init && chmod +x /usr/local/bin/dumb-init \
  && apt-get install -y apt-transport-https ca-certificates curl gnupg hicolor-icon-theme libgl1-mesa-dri libgl1-mesa-glx libpulse0 libv4l-0 --no-install-recommends \
	&& curl -sSL https://dl.google.com/linux/linux_signing_key.pub | apt-key add - \
	&& echo "deb [arch=amd64] https://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google.list \
	&& apt-get update && apt-get install -y google-chrome-unstable --no-install-recommends \
  && wget https://raw.githubusercontent.com/jfrazelle/dockerfiles/master/chrome/stable/local.conf -O /etc/fonts/local.conf \
  && groupadd -r chrome && useradd -r -g chrome -G audio,video chrome \
  && mkdir -p /home/chrome/Downloads && chown -R chrome:chrome /home/chrome \
  && echo 'nohup sh -c "google-chrome --headless --hide-scrollbars --remote-debugging-port=9222 --disable-gpu" > /dev/null &' > /home/chrome/start-chrome.sh \
  && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
  && pip install awscli \
  && mkdir -p /usr/src/app/{client,server/modules} \

ADD server/package.json /usr/src/app/server/package.json
ADD client/package.json client/bower.json /usr/src/app/client/
RUN cd /usr/src/app/client && npm install && npm run postinstall \
  && cd /usr/src/app/server && npm install

WORKDIR /usr/src/app

ENTRYPOINT ["dumb-init"]

CMD ["bash"]
