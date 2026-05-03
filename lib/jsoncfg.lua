 function json(filePath)

    local filePath = (filePath:find('(.+).txt') and filePath or filePath..'.txt')
    local class = {}
    if not doesDirectoryExist(getWorkingDirectory() .. '\\config') then
        createDirectory(getWorkingDirectory() .. '\\config')
    end

    function class:Save(tbl)
        if tbl then
            local F = io.open(filePath, 'w')
            F:write(encodeJson(tbl) or {})
            F:close()
            return true, 'ok'
        end
        return false, 'table = nil'
    end

    function class:Load(defaultTable)
        if not doesFileExist(filePath) then
            class:Save(defaultTable or {})
        end
        local F = io.open(filePath, 'r+')
        local TABLE = decodeJson(F:read() or {})
        F:close()
        for def_k, def_v in next, defaultTable do
            if TABLE[def_k] == nil then
                TABLE[def_k] = def_v
            end
        end
        return TABLE
    end

    return class
end