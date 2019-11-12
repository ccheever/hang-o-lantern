require 'rook'

local spooky_words = require './spooky_words'

-- The layout of a keyboard
local qwerty = {
    {'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p'},
    {'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l'},
    {'z', 'x', 'c', 'v', 'b', 'n', 'm'}
}

local game_state

local frames
local font

function setup()
    init_game()
    draw_keyboard()
    load_scene_frames()
    font = graphics.newFont(30)
end

function load_scene_frames()
    frames = {}
    for i = 0, 6 do
        frames[i] = graphics.newImage("./img" .. i .. "@3x.png")
    end
end

function init_game()
    game_state = {
        state = 'play',
        word = randchoice(spooky_words),
        guessed = {},
        wrong = {},
        strikes = 0
    }
end

function reset()
    init_game()
end

function draw()
    draw_strikes()
    draw_keyboard()
    draw_word()
    draw_guessed()
    draw_state()
end

function draw_strikes()
    local s = 800 / 294
    local strikes = game_state.strikes
    if strikes > 6 then strikes = 6 end
    graphics.setColor(1, 1, 1, 1)
    graphics.draw(frames[strikes], 0, 0, 0)
end


function draw_state()
    local x = 220
    local y = 720
    graphics.setColor(1, 1, 1, 1)
    -- graphics.print(game_state.state, x, y)
    -- graphics.print(game_state.strikes .. ' strikes', x, y + 20)
    if game_state.state ~= 'play' then
        graphics.setFont(font)
        graphics.setColor(1, 1, 1, 1)
        graphics.print("You " .. game_state.state .. "!", x, y + 25)
        graphics.print('The word was ', x, y + 50)
        graphics.print(string.upper(game_state.word), x, y + 75, 0, 2, 2)
        graphics.print('Tap to play again', x, y + 150)
    end
end

function draw_word()
    local x = 20
    local y = 1200
    local s = 36
    local p = 10

    for i = 1, #game_state.word do
        local c = string.sub(game_state.word, i, i)
        local reveal = false
        for j = 1, #game_state.guessed do
            if game_state.guessed[j] == c then
                reveal = true
            end
        end

        local x_ = x + (i - 1) * (s + p)
        local y_ = y

        if c == ' ' then
            -- skip spaces
        else
            graphics.setColor(1, 0.5, 0, 1) -- fc6800
            graphics.rectangle('fill', x_, y_, s, s + p)
            local dc = '_'
            if reveal then
                dc = c
            end
            graphics.setColor(0.2, 0.2, 0.2, 1)
            graphics.setFont(font)
            graphics.print(string.upper(dc), x_ + p / 2, y_ + p / 2)
        end
    end
end

function draw_guessed()
    local x = 20
    local y = 20
    local s = 30
    local p = 4
    for i = 1, #game_state.guessed do
        local x_ = x + (i - 1) * (s + p)
        local y_ = y
        graphics.setColor(1, 1, 1, 1)
        graphics.setFont(font)
        graphics.print(string.upper(game_state.guessed[i]), x_, y_)
    end
end

function render_keyboard(f)
    -- This function takes a callback function `f`
    -- that it calls for each letter on the keyboard
    -- once the layout position for it is computed.
    -- This way, we can use the same code/logic for
    -- drawing the keyboard and also handling touches

    local x = 20
    local y = 920
    local s = 50
    local p = 12

    for row = 1, #qwerty do
        local row_letters = qwerty[row]
        for col = 1, #row_letters do
            local letter = row_letters[col]
            local x_ = x + (s + p) * col + row * s / 3
            local y_ = y + (s + p) * row
            if iscallable(f) then
                f(letter, x, y, s, p, x_, y_)
            end
        end
    end
end

function draw_keyboard()
    -- Draw a box with a letter in it at each position we want to render a key

    render_keyboard(
        function(letter, x, y, s, p, x_, y_)
            graphics.setColor(1, 1, 1, 0.25)
            graphics.rectangle('fill', x_, y_, s, s)
            graphics.setColor(0, 0, 0, 1)
            graphics.print(letter, x_ + p / 2, y_ + p / 2)
        end
    )
end

function reset_game()
    init_game()
end

function guess_letter(letter)
    -- Check to see if this letter has already been guessed
    for i = 1, #game_state.guessed do
        if letter == game_state.guessed[i] then
            -- Maybe do some kind of error?
            return
        end
    end

    table.insert(game_state.guessed, letter)

    local in_word = false
    for i = 1, #game_state.word do
        if string.sub(game_state.word, i, i) == letter then
            in_word = true

            -- If we just guessed a letter that is in the word, then
            -- maybe we just won; check for that
            if is_game_won() then
                game_state.state = 'win'
            end

            break
        end
    end

    -- If the letter isn't in the word, you get a strike
    -- If you get too many strikes, you lose
    if not in_word then
        game_state.strikes = game_state.strikes + 1
        if game_state.strikes >= 5 then
            game_state.state = 'lose'
        end
    end
end

function is_game_won()
    -- Loop over each letter in the word and check to see if its guessed
    -- If every letter in the word has been guessed, then we win
    for i = 1, #game_state.word do
        local ic = string.sub(game_state.word, i, i)
        local guessed = false
        for j = 1, #game_state.guessed do
            local jc = game_state.guessed[j]
            if ic == jc then
                guessed = true
                break
            end
        end

        -- N.B. Spaces don't have to be guessed
        if not guessed and ic ~= ' ' then
            return false
        end
    end

    -- Every letter in the word has been guessed; we win!
    return true
end

-- Handle taps and mouseclicks the same way, by checking to see if they are
-- inside any boxes in the virtual keyboard
function mousepressed(x, y, button, istouch, presses)
    if game_state.state ~= 'play' then
        reset_game()
        return
    end

    render_keyboard(
        function(letter, lx, ly, s, p, x_, y_)
            if x > x_ and x < x_ + s and y > y_ and y < y_ + s then
                guess_letter(letter)
            end
        end
    )
end

-- Handle keypresses so that if you're playing on desktop, you can
-- use your physical keyboard
function keypressed(key, scancode, isrepeat)
    if game_state.state ~= 'play' then
        if key == 'space' then
            reset_game()
        end
        return
    end

    -- Check to make sure that the length of `key` is one so we
    -- don't guess things like 'rshift' etc.
    if key >= 'a' and key <= 'z' and #key == 1 then
        guess_letter(key)
    end
end
