-- BetterWait | Version 1

--[[
    Description - Waits for the specified child to load and returns it if found.
    Parameters -
        [object] parent - The childs parent
        [string] child - The specified child to wait for
        [boolean] isRecursive - Whether or not to search recursively for the child
        [number] timeout - The max amount of time to search before timing out
    Returns - The loaded child or nil if it times out
    Errors - If no parent and child were specified
]]
local function betterWait(parent, child, timeout, isRecursive)
    if not parent then
        warn("No parent specified")

        return nil
    end
    
    if not child then
        warn("No child specified")

        return nil
    end

	timeout = timeout or 30
    isRecursive = isRecursive or false
	
    local _startingTick = tick()
    
    local function search()
        if tick() - _startingTick >= timeout then
            warn("BetterWait timed out looking for " .. child)

            return nil
        end

        local _foundChild = parent:FindFirstChild(child, isRecursive)

        if not _foundChild then
            task.wait(1)
        
            return search()
        else
            return _foundChild
        end
    end

    return search()
end

return betterWait

