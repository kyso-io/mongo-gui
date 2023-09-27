# Global Dockerfile Arguments (in our CI can be overriden in ./.build-args)
ARG SERVICE_IMG=node 
ARG SERVICE_TAG=16.16.0-alpine3.16

FROM ${SERVICE_IMG}:${SERVICE_TAG}

RUN apk update && apk add --no-cache dumb-init && rm -rf /var/cache/apk/* &&\
 printf "Installed npm version: " && npm --version &&\
 npm update --location=global npm &&\
 printf "Installed npm version: " && npm --version &&\
 rm -rf ~/.npm ~/.gnupg

COPY ./container-entrypoint.sh /

ENTRYPOINT ["/bin/sh", "/container-entrypoint.sh"]

# Set the NODE_ENV value from the args
ARG NODE_ENV=production
## Export the NODE_ENV to the container environment
ENV NODE_ENV=${NODE_ENV}
### For security reasons don't run as root
USER node
### Change the working directory to /app
WORKDIR /app
## Copy the complete /app dir
COPY --chown=node:node . ./
## Install everything
RUN npm install
## Start the server using our script
CMD ["/bin/sh", "/app/start-server.sh"]
