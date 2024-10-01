FROM openresty/openresty:1.25.3.2-0-alpine-fat

COPY nginx.conf /usr/local/openresty/nginx/conf/nginx.conf

COPY rate_limit.lua /usr/local/openresty/nginx/conf/rate_limit.lua

COPY index.html /usr/local/openresty/nginx/html/index.html

CMD ["nginx", "-g", "daemon off;"]