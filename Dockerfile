# build environment
FROM node:19-alpine as build
WORKDIR /app
COPY package*.json ./
RUN ["npm","ci"]
COPY ./ ./
EXPOSE 80
RUN ["npm", "run","build"]

# production environment
FROM nginx:1.21.6-alpine
COPY --from=build /app/build /usr/share/nginx/html
# new
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]