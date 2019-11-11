local iscallable = require "./iscallable"

-- -- Dump everything from `love` into the global namespace
local function dump(t)
    for name, val in pairs(t) do
        if type(val) == 'table' then
            -- print('table: ' .. name)
            dump(val)
        else
            -- log('value: ' .. name .. ' = ', val)
            if _G[name] ~= nil or name == 'draw' or name == 'load' or name == 'update' then
                if _G[name] == val then
                    -- print('redundant collision for ' .. name)
                else
                    -- print('collision around ' .. name)
                end
            else
                -- print('Making global for ' .. name)
                _G[name] = val
            end
        end
    end
end

-- We set some values for these functions so
-- that if you define `load` or `update` or `draw`,
-- those will just be used; but if you define
-- `love.draw`, etc., that will work too.
-- The `pcall` is to make sure things don't break
-- if you don't define some of the gameloop functions


function love.load(...)
    if iscallable(setup) then
        return setup(...)
    end
end

function love.update(dt, ...)
    if iscallable(update) then
        return update(dt, ...)
    end
end

function love.draw(...)
    if iscallable(draw) then
        return draw(...)
    end
end

--[[
`log` takes any number of arguments and prints them 
out as a comma separated list. Anything other than 
strings will be pretty-printed using serpent.
]]
-- local serpent =
--     require(
--     'https://raw.githubusercontent.com/pkulchenko/serpent/522a6239f25997b101c585c0daf6a15b7e37fad9/src/serpent.lua'
-- )
local serpent = require './serpent'

function log(...)
    local out = {}
    for i, obj in ipairs({...}) do
        if type(obj) == 'string' then
            table.insert(out, obj)
        else
            table.insert(out, serpent.line(obj))
        end
    end
    print(table.concat(out, ', '))
end

-- dump(love.graphics)
text = love.graphics.print
drawGraphic = love.graphics.draw

Object = require './classic'
SpriteSheet = require './SpriteSheet'
graphics = love.graphics

function love.keypressed(...)
    if iscallable(keypressed) then
        return keypressed(...)
    end
end

function love.touchpressed(...)
    if iscallable(touchpressed) then
        return touchpressed(...)
    end
end


function randchoice(t)
    return t[math.random(#t)]
end

function randomseedtime()
    if type(socket) == "table" then
        math.randomseed(socket.gettime())
    else
        math.randomseed(os.time())
    end
end
randomseedtime()

return {
    log = log,
    Object = Object,
    text = love.graphics.print,
    drawGraphic = love.graphics.draw,
    iscallable = iscallable,
    randchoice = randchoice,
    randomseedtime = randomseedtime,
}
