# dynamic-rate-limiting-blog

This code is a simplified version of Dynamic Rate Limiting implemented for a Real time usecase.

It allows you to set rate limits for different routes and based on Client usage plan, restricts the number of requests a client can make to a route.

You can read the blog here [Dynamic Rate Limiting](https://ezyinfra.com/dynamic-rate-limiting/)

## Features

- Set rate limits for different routes based on client usage plan
- Use Redis to store rate limit data
- Implements Sliding Window Rate Limiting algorithm

## Usage

1. Clone the repository
```
git clone https://github.com/ezyinfra/dynamic-rate-limiting-blog.git
```
2. Build and Run the Docker compose
```
docker compose build && docker compose up
```
3. Initialize Redis with sample API keys and rate limit parameters
```
docker exec -it <container-id> redis-init.sh
```
4. Test the rate limiting by making multiple requests to the server using ApacheBench (ab)
```
ab -n 100 -c 10 -H "api-key:api_key_1" http://localhost:80/
```

## References

- [OpenResty](https://openresty.org/)
- [Redis](https://redis.io/)
- [Sliding Window Rate Limiting](https://www.nginx.com/blog/rate-limiting-nginx/)
