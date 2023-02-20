FROM node:19-alpine

ARG user=app
ARG home=/home/$user
RUN addgroup -S $user
RUN adduser \
    --disabled-password \
    --gecos "" \
    --home $home \
    --ingroup $user \
    $user
WORKDIR $home

COPY --chown=node package.json ./

RUN wget -O /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.5/dumb-init_1.2.5_x86_64 \
  && chmod +x /usr/local/bin/dumb-init \
  && npm install -g coffeescript \
  && npm install --production

COPY --chown=node . ./

USER $user

EXPOSE 3000

ENTRYPOINT ["/usr/local/bin/dumb-init", "--"]
CMD ["coffee", "src/web.coffee"]
