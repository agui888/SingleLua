--
-- Created by IntelliJ IDEA.
-- User: leandre
-- Date: 16/1/13
-- Time: 下午1:53
--

local _M = sys_controller

--- test init action
--
function _M:init()
    ngx.say("controller init");
end

--- test index action
--
function _M:index()
    ngx.say("controller index");
    -- self:succ("", "", { 1, 2, 3 })
    -- self:error("", "", { 4, 5, 6 })
end

return _M