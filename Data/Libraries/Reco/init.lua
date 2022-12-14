--[[
    Reco
    Version 1
    Started on 10/25/2022
]]

-- Root
local RECO = {}

-- Local Functions
local function iterate(tbl, last, fn, ...)
    local _key, _value = next(tbl, last)
    
    if not _key then
        return ... or nil
    end
    
    return iterate(tbl, _key, fn, fn(_key, _value, ...))
end

-- Global Functions
function RECO.each(tbl, fn, ...)
    return iterate(tbl, nil, fn, ...)
end

return RECO
