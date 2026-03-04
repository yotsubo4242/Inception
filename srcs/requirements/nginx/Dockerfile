FROM debian:latest

RUN apt-get update && apt-get install -y nginx

EXPOSE 4242

COPY conf.d/ /etc/nginx/conf.d/

CMD ["nginx", "-g", "daemon off;"]
