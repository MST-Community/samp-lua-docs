--// ezjson.lua by chapo
--// Version 0.2
--// Works with moonloader or https://github.com/rxi/json.lua

local jsonModuleStatus, jsonModule = pcall(require, 'json');
local DIR = getWorkingDirectory and getWorkingDirectory() or '';
local jsonEncoder = {
    encode = encodeJson or (jsonModuleStatus and jsonModule.encode or nil), ---@diagnostic disable-line:undefined-global
    decode = decodeJson or (jsonModuleStatus and jsonModule.decode or nil) ---@diagnostic disable-line:undefined-global
}
assert(jsonEncoder.encode and jsonEncoder.decode, 'error, cannot use json encode/decode functions. Install JSON cfg: https://github.com/rxi/json.lua');


---@param path string File path
---@return boolean status Does file exists
local function doesFileExists(path)
    local f = io.open(path, 'r');
    if (f ~= nil) then io.close(f) end
    return f ~= nil;
end

---@param file string
---@param default table
---@return boolean status
---@return table config
---@return string? message
function Json(file, default)
    if (not file:find('(.+)%.json$')) then
        file = file .. '.json';
    end
    
    -- local file = file:find('\\') and DIR .. '\\' .. file or DIR .. '\\config\\' .. file;
    -- if (file:sub(1, 1) == '\\') then
    --     file = file:sub(2, #file);
    -- end
    -- print(file)
    local json, status, message = {}, false, 'UNKNOWN_ERROR';

    ---@private
    local function tableToString(tbl, indent)
        local function formatTableKey(k)
            local defaultType = type(k);
            if (defaultType ~= 'string') then
                k = tostring(k);
            end
            local useSquareBrackets = k:find('^(%d+)') or k:find('(%p)') or k:find('\\') or k:find('%-');
            return useSquareBrackets == nil and k or ('[%s]'):format(defaultType == 'string' and "'" .. k .. "'" or k);
        end
        local str = { '{' };
        local indent = indent or 0;
        for k, v in pairs(tbl) do
            table.insert(str, ('%s%s = %s,'):format(string.rep("    ", indent + 1), formatTableKey(k), type(v) == "table" and tableToString(v, indent + 1) or (type(v) == 'string' and "'" .. v .. "'" or tostring(v))));
        end
        table.insert(str, string.rep('    ', indent) .. '}');
        return table.concat(str, '\n');
    end

    ---@private
    ---@param default table Default values
    ---@param current table Current values
    local function __fillEmptyKeys(default, current)
        local filledCount = 0;
        for key, value in pairs(default) do
            if (current[key] == nil) then
                if (type(value) == 'table') then
                    current[key] = {};
                    _, subFilledCount = __fillEmptyKeys(value, current[key]);
                    filledCount = filledCount + subFilledCount;
                else
                    current[key] = value;
                    filledCount = filledCount + 1;
                end
            elseif (type(value) == 'table' and type(current[key]) == 'table') then
                _, subFilledCount = __fillEmptyKeys(value, current[key]);
                filledCount = filledCount + subFilledCount;
            end
        end
    
        return current, filledCount
    end

    ---@private
    ---@param data table
    local function __write(data)
        local F = io.open(file, 'w');
        if (F) then
            local encodeStatus, encodeResult = pcall(jsonEncoder.encode, data);
            if (encodeStatus and encodeResult) then F:write(encodeResult) end
            F:close();
        end
    end

    ---@private
    ---@return table data Decoded data
    local function __read()
        local F = io.open(file, 'r');
        if (F) then
            local text = F:read('*a');
            F:close();
            local decodeStatus, decodeResult = pcall(jsonEncoder.decode, text);
            if (decodeStatus and decodeResult) then
                json = decodeResult;
                status = true;
                local newData, filledCount = __fillEmptyKeys(default, json);
                if filledCount > 0 then
                    __write(newData);
                    return newData;
                end
                return decodeResult;
            else
                message = 'JSON_DECODE_FAILED_'..decodeResult;
            end
        else
            message = 'JSON_FILE_OPEN_FAILED';
        end
        return {};
    end

    if (not doesFileExists(file)) then
        __write(default);
    end

    json = __read();
    return status, setmetatable({}, {
        __call = function(self, arg)
            if (type(arg) == 'table') then
                json = arg;
                __write(json);
            end
        end,
        __index = function(self, key)
            return key and json[key] or json;
        end,
        __newindex =  function(self, key, val)
            json[key] = val;
            __write(json);
        end,
        __tostring = function(self)
            return tableToString(json);
        end,
        __pairs = function()
            local key, value = next(json);
            return function()
                key, value = next(json, key);
                return key, value;
            end
        end,
        __concat = function()
            return jsonEncoder.encode(json);
        end
    }), status and 'ok' or message;
end

return Json;