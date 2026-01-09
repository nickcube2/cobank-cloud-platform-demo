FROM nginx:alpine

COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy the static site (index + assets)
COPY index.html /usr/share/nginx/html/index.html
COPY assets /usr/share/nginx/html/assets

