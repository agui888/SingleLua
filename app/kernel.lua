--
-- kernel
-- User: leandre
-- Date: 16/1/15
-- Time: 下午12:11
--

local _K = { _VERSION = 0.1 }

--- call bootstrap function list
--
function _K:bootstrap()
    local bootstrap = require("app.bootstrap")

    for k, v in pairs(bootstrap) do
        if string.sub(k, 1, 4) == "init" then
            v()
        end
    end
end

--- call all hook functions
-- @param hook_tab
--
function _K:hook_run(hook_tab)
    for _, v in ipairs(hook_tab) do
        v()
    end
end

--- not found
--
function _K:not_found()
    ngx.status = ngx.HTTP_NOT_FOUND
    ngx.say("File not found.")
    ngx.exit(ngx.HTTP_NOT_FOUND)
end

--- handle request
--
function _K:request()
    ngx.req.read_body()
    return {
        http_method = ngx.req.get_method(),
        http_headers = ngx.req.get_headers(),
        http_get_params = ngx.req.get_uri_args(),
        http_post_params = ngx.req.get_post_args()
    }
end

--- kernel run
--
function _K:run()
    local app_config = require("app.config.app")
    local tools = require(app_config["lib_path"] .. "tools")
    local container = require(app_config["lib_path"] .. "container")

    local uri_arr = tools.array_filter(tools.lua_string_split("/", ngx.var.uri))
    local ctr_file = tools.lua_string_merge(".", uri_arr)

    -- default index
    if ctr_file == "" then
        ctr_file = "index"
    end

    container['ctr_file'] = ctr_file

    -- init all hook functions table
    container['routerStartup'] = {}
    container['routerShutdown'] = {}
    container['preDispatch'] = {}
    container['postDispatch'] = {}

    -- request params
    container['request'] = self:request()

    self:bootstrap()

    self:hook_run(container['routerStartup'])
    ctr_file = app_config['ctr_path'] .. container['ctr_file']
    self:hook_run(container['routerShutdown'])

    local ctr_cache = ngx.shared.ctrs:get(ctr_file)

    if ctr_cache == nil then
        local ctr_realpath = ngx.var.document_root .. '/' .. tools.lua_string_merge("/", tools.lua_string_split("%.", ctr_file)) .. ".lua"
        local file = io.open(ctr_realpath, "r")
        if file == nil then
            ngx.shared.ctrs:set(ctr_file, 0)
            self:not_found()
        else
            ngx.shared.ctrs:set(ctr_file, 1)
        end
        io.close(file)
    elseif ctr_cache == 0 then
        self:not_found()
    end

    local ctr = require(ctr_file)
    container["ctr_content"] = ctr;
    self:hook_run(container['preDispatch'])
    ctr:new()
    self:hook_run(container['postDispatch'])
end

return _K