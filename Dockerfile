# Global Dockerfile Arguments (in our CI can be overriden in ./.build-args)
ARG SERVICE_IMG=registry.kyso.io/docker/node-service
ARG SERVICE_TAG=fixme

FROM ${SERVICE_IMG}:${SERVICE_TAG}
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
