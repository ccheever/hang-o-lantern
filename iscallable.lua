function iscallable(x)
    if type(x) == 'function' then
        return true
    elseif type(x) == 'table' then
        -- It would be elegant and quick to say
        -- `return iscallable(debug.getmetatable(x).__call)`
        -- but that is actually not quite correct
        -- (at least in my experiments), since it appears
        -- that the `__call` metamethod must be a *function value*
        -- (and not some table that has been made callable)
        local mt = debug.getmetatable(x)
        return type(mt) == "table" and type(mt.__call) == "function"
    else
        return false
    end
end

return iscallable
