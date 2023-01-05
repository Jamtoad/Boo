-- Reco | Version 2
-- Version 1: Initial release.
-- Version 2: Restructure and comments added!

--[[
    Description - Recursively loops through a table and runs the specified
    function
    
    Parameters -
        [table] tbl - The table to iterate through
        [function] fn - The function to run upon each iteration
        [tuple] ... - Any arguments to pass through to the function

    Returns - Return anything the called function returns or nil
]]

-- Local Functions
local function iterate(tbl, last, fn, ...)
    local _key, _value = next(tbl, last)
    
    if not _key then
        return ... or nil
    end
    
    return iterate(tbl, _key, fn, fn(_key, _value, ...))
end

function each(tbl, fn, ...)
    return iterate(tbl, nil, fn, ...)
end

return each
