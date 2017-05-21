FROM mhart/alpine-node:7

WORKDIR /home/node

ADD https://github.com/Yelp/dumb-init/releases/download/v1.2.0/dumb-init_1.2.0_amd64 /usr/bin/dumb-init

COPY package.json ./

RUN \
  chmod +x /usr/bin/dumb-init \
  && adduser -D node \
  && npm install -g coffee-script \
  && npm install --production

COPY . ./

RUN chown -R node.node .

EXPOSE 3000

USER node

ENTRYPOINT ["/usr/bin/dumb-init", "--"]

CMD ["coffee", "src/web.coffee"]
