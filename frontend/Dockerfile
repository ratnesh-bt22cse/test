FROM node:18-alpine AS buildFROM node:18-alpine AS build# Build stage



WORKDIR /appFROM node:18-alpine as build



COPY package*.json ./WORKDIR /app



RUN npm installWORKDIR /app



COPY . .COPY package*.json ./



ARG REACT_APP_API_URLRUN npm install# Copy package files

ENV REACT_APP_API_URL=$REACT_APP_API_URL

COPY package*.json ./

RUN npm run build

COPY . .

FROM nginx:alpine

# Install dependencies

COPY nginx.conf /etc/nginx/conf.d/default.conf

ARG REACT_APP_API_URLRUN npm install

COPY --from=build /app/build /usr/share/nginx/html

ENV REACT_APP_API_URL=$REACT_APP_API_URL

EXPOSE 80

# Copy source code

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \

  CMD wget --no-verbose --tries=1 --spider http://localhost:80 || exit 1RUN npm run buildCOPY . .



CMD ["nginx", "-g", "daemon off;"]


FROM nginx:alpine# Build argument for API URL

ARG REACT_APP_API_URL=http://localhost:5000/api

COPY nginx.conf /etc/nginx/conf.d/default.confENV REACT_APP_API_URL=$REACT_APP_API_URL

COPY --from=build /app/build /usr/share/nginx/html

# Build the application

EXPOSE 3000RUN npm run build



CMD ["nginx", "-g", "daemon off;"]# Production stage - serve with nginx

FROM nginx:alpine

# Copy custom nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy build files from build stage
COPY --from=build /app/build /usr/share/nginx/html

# Expose port
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:80 || exit 1

CMD ["nginx", "-g", "daemon off;"]
