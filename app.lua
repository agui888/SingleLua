--
-- app
-- User: leandre
-- Date: 16/1/15
-- Time: 下午12:17
--

-- dev / pro
local env = "dev"

local kernel = require("app.kernel")

local status, error = pcall(function()
    kernel:run()
end)

if status == false then
    ngx.status = ngx.HTTP_INTERNAL_SERVER_ERROR
    if env == "pro" then
        ngx.say("HTTP_INTERNAL_SERVER_ERROR")
    else
        ngx.say(error)
    end
    ngx.log(ngx.ERR, error)
    ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
end