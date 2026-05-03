-- LoadString Library for SAMP - Simple Syntax with Auto Anti-Lag (Fixed)
-- Usage: require("loadstring")("https://pastebin.com/raw/EAypfPeq")

local effil = require('effil')
local encoding = require('encoding')
local u8 = encoding.UTF8
encoding.default = 'CP1251'

-- Cache para scripts
local script_cache = {}
local execution_cache = {}
local downloading = {} -- Estado de descargas

-- Función para convertir URLs automáticamente
local function convert_url(url)
    local pastebin_id = url:match("pastebin%.com/([^/]+)$")
    if pastebin_id and not url:match("/raw/") then
        return "https://pastebin.com/raw/" .. pastebin_id
    end
    
    local github_raw = url:gsub("github%.com", "raw.githubusercontent.com"):gsub("/blob/", "/")
    if github_raw ~= url then
        return github_raw
    end
    
    return url
end

-- Función para descargar con effil (sin wait en función principal)
local function start_download(url)
    local normalized_url = convert_url(url)
    
    -- Si ya se está descargando, no iniciar otro
    if downloading[normalized_url] then
        return false
    end
    
    downloading[normalized_url] = true
    
    -- Crear thread de descarga
    local download_thread = effil.thread(function(url)
        local http = require('socket.http')
        local ltn12 = require('ltn12')
        local response = {}
        local res, code, headers = http.request{
            url = url,
            sink = ltn12.sink.table(response),
            headers = {
                ["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
            },
            timeout = 8
        }
        
        if code == 200 then
            return true, table.concat(response)
        elseif code == 301 or code == 302 then
            local redirect = headers.location or headers.Location
            if redirect then
                return "redirect", redirect
            else
                return false, "Redirección sin destino"
            end
        else
            return false, "HTTP Error " .. tostring(code)
        end
    end)(normalized_url)
    
    -- Manejar resultado en thread separado
    lua_thread.create(function()
        while true do
            local status, err = download_thread:status()
            if not err then
                if status == 'completed' then
                    local success, result, extra = download_thread:get()
                    downloading[normalized_url] = nil
                    
                    if success == true then
                        script_cache[normalized_url] = result
                    elseif success == "redirect" then
                        -- Iniciar descarga de redirección
                        start_download(result)
                    else
                        script_cache[normalized_url] = "ERROR: " .. result
                    end
                    break
                elseif status == 'canceled' then
                    downloading[normalized_url] = nil
                    script_cache[normalized_url] = "ERROR: Descarga cancelada"
                    break
                end
            else
                downloading[normalized_url] = nil
                script_cache[normalized_url] = "ERROR: " .. err
                break
            end
            wait(0)
        end
    end)
    
    return true
end

-- Función principal que se ejecuta cuando haces require("loadstring")
local function loadstring_main(url)
    if type(url) ~= "string" then
        error("LoadString: URL debe ser un string")
    end
    
    if not url:match("^https?://") then
        error("LoadString: URL inválida - debe empezar con http:// o https://")
    end
    
    local normalized_url = convert_url(url)
    
    -- Si ya se ejecutó, devolver resultado del cache
    if execution_cache[normalized_url] then
        return execution_cache[normalized_url]
    end
    
    -- Si está en cache de scripts, ejecutar inmediatamente
    if script_cache[normalized_url] then
        local script_content = script_cache[normalized_url]
        
        -- Si es un error, mostrarlo
        if script_content:match("^ERROR:") then
            error("LoadString: " .. script_content:sub(8)) -- Quitar "ERROR: "
        end
        
        local func, err = load(script_content, "@" .. normalized_url)
        if not func then
            error("LoadString: Error de compilación - " .. err)
        end
        
        local success, result = pcall(func)
        if not success then
            error("LoadString: Error de ejecución - " .. result)
        end
        
        execution_cache[normalized_url] = result
        return result
    end
    
    -- Si no está en cache, iniciar descarga y usar versión síncrona como fallback
    if not downloading[normalized_url] then
        start_download(url)
    end
    
    -- Fallback síncrono para compatibilidad inmediata
    local http = require('socket.http')
    local ltn12 = require('ltn12')
    local response = {}
    local res, code, headers = http.request{
        url = normalized_url,
        sink = ltn12.sink.table(response),
        headers = {
            ["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
        },
        timeout = 5 -- Timeout corto para fallback
    }
    
    local script_content = nil
    
    if code == 200 then
        script_content = table.concat(response)
        script_cache[normalized_url] = script_content
    elseif code == 301 or code == 302 then
        local redirect = headers.location or headers.Location
        if redirect then
            return loadstring_main(redirect)
        else
            error("LoadString: Redirección sin destino")
        end
    else
        error("LoadString: HTTP Error " .. tostring(code))
    end
    
    -- Compilar y ejecutar
    local func, load_err = load(script_content, "@" .. normalized_url)
    if not func then
        error("LoadString: Error de compilación - " .. (load_err or "error desconocido"))
    end
    
    local success, result = pcall(func)
    if not success then
        error("LoadString: Error de ejecución - " .. tostring(result))
    end
    
    -- Guardar en cache de ejecución
    execution_cache[normalized_url] = result
    return result
end

-- Crear tabla con metatable para funcionar como función
local loadstring_lib = {}

setmetatable(loadstring_lib, {
    __call = function(self, url)
        return loadstring_main(url)
    end
})

-- Función para limpiar caches
loadstring_lib.clear_cache = function()
    script_cache = {}
    execution_cache = {}
    downloading = {}
end

-- Función para estadísticas
loadstring_lib.stats = function()
    local script_count = 0
    local exec_count = 0
    local downloading_count = 0
    
    for url, content in pairs(script_cache) do
        if not content:match("^ERROR:") then
            script_count = script_count + 1
        end
    end
    
    for _ in pairs(execution_cache) do
        exec_count = exec_count + 1
    end
    
    for _ in pairs(downloading) do
        downloading_count = downloading_count + 1
    end
    
    return {
        scripts_cached = script_count,
        executions_cached = exec_count,
        downloading = downloading_count
    }
end

return loadstring_lib