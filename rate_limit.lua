local redis = require "resty.redis"

local red = redis:new()
red:set_timeout(5000) -- 5 seconds

-- Update the Redis connection to use the service name and port
local ok, err = red:connect("redis", 6379)
if not ok then
    ngx.log(ngx.ERR, "Failed to connect to Redis: ", err)
    return ngx.exit(500)
end

-- Add this line to keep the connection alive
-- local ok, err = red:set_keepalive(10000, 100)
-- if not ok then
--     ngx.log(ngx.ERR, "Failed to set keepalive: ", err)
-- end

-- Get the user's IP address
local user_ip = ngx.var.remote_addr

local headers = ngx.req.get_headers()
local api_key = headers["api-key"]
if not api_key or api_key == ngx.null  then
    ngx.log(ngx.ERR, "API Key not found")
    return ngx.exit(403)
end

-- Fetch the rate limit parameters from Redis
local redis_key = "rateLimit:" .. api_key

local rate_limit_params, err = red:hgetall(redis_key)
if not rate_limit_params or #rate_limit_params == 0 then
    ngx.log(ngx.ERR, "Invalid API Key or empty rate limit parameters")
    return ngx.exit(403)
end

local rate_limit_hash = {}
for i = 1, #rate_limit_params, 2 do
  rate_limit_hash[rate_limit_params[i]] = rate_limit_params[i + 1]
end

-- Actual Rate Limiting Logic
local function rate_limit(key, window, max_requests)
    -- Get the current time
    local current_time = ngx.now() -- Get the current time as a float
    -- Check if the key exists
    local key_exists, err = red:exists(key)
    if not key_exists then
        ngx.log(ngx.ERR, "Error checking key existence: ", err)
        return ngx.exit(500)
    end

    -- Get the current request count
    local request_count = 0
    if key_exists == 1 then
        -- Remove outdated entries
        local trim_time = current_time - window
        local res, err = red:zremrangebyscore(key, "-inf", trim_time)
        if not res then
            ngx.log(ngx.ERR, "Error removing outdated entries: ", err)
            return ngx.exit(500)
        end
        
        -- Get the current request count
        res, err = red:zcard(key)
        if not res then
            ngx.log(ngx.ERR, "Error getting request count: ", err)
            return ngx.exit(500)
        end
        request_count = res
    end
    ngx.log(ngx.ERR, "Request count", request_count, ", Max Requests", max_requests)

    if request_count < max_requests then
        local res, err = red:zadd(key, current_time, current_time)
        if not res then
            ngx.log(ngx.ERR, "Error adding new request: ", err)
            return ngx.exit(500)
        end

        local res, err = red:expire(key, window)
        if not res then
            ngx.log(ngx.ERR, "Error setting key expiry: ", err)
            return ngx.exit(500)
        end

        return 0  -- Indicate that the request is allowed
    end

    -- If over limit, return 1
    return 1
end

local max_requests = tonumber(rate_limit_hash["max_requests"])
local window_duration = tonumber(rate_limit_hash["window_duration"])

ngx.log(ngx.ERR, "Max Requests: ", max_requests, ", Window Duration: ", window_duration)

local window_key = "rateLimit:" .. api_key .. ":window" 
result = rate_limit(window_key, window_duration, max_requests)
if result == 1 then
    ngx.log(ngx.ERR, "Rate limit exceeded for API key: ", api_key, ", IP Address: ", user_ip, ", Endpoint: ", request_path, ", Interval: ", "1m")
    return ngx.exit(429)
end
