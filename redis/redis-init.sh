#!/bin/sh

# Initialize Redis with sample API keys and rate limit parameters
redis-cli HSET rateLimit:api_key_1 max_requests 100 window_duration 60
redis-cli HSET rateLimit:api_key_2 max_requests 50 window_duration 30
redis-cli HSET rateLimit:api_key_3 max_requests 200 window_duration 120

echo "Redis initialization completed."