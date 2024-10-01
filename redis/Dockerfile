FROM redis:alpine

COPY redis-init.sh /usr/local/bin/
COPY redis.conf /usr/local/etc/redis/redis.conf

RUN chmod +x /usr/local/bin/redis-init.sh

CMD ["sh", "-c", "redis-server /usr/local/etc/redis/redis.conf"]