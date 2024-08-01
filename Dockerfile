# base node image
FROM node:20-bullseye-slim as base

# Build the dev image
FROM base as build
RUN mkdir /app/
WORKDIR /app/
COPY . /app
RUN npm install
RUN npm run build

# Get the production modules
FROM base as production-deps
RUN mkdir /app/
WORKDIR /app/
COPY --from=build /app/node_modules /app/node_modules
ADD package.json package-lock.json /app/
RUN npm prune --production

# Finally, build the production image with minimal footprint
FROM base
ENV NODE_ENV=production
ENV HOST=0.0.0.0
ENV PORT=8080
RUN mkdir /app/
WORKDIR /app/
ADD package.json package-lock.json /app/
COPY --from=build /app/build /app/build
COPY --from=build /app/public/build /app/public/build
COPY --from=production-deps /app/node_modules /app/node_modules
CMD ["npm", "start"]
EXPOSE $PORT
