#Frontend Dockerfile

#Using Nginx to host web server
FROM nginx:stable-alpine

#Copy build files from app to static folder
COPY . /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]


