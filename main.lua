require 'rook'

local spooky_words = require './spooky_words'

local qwerty = {
    {'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p'},
    {'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l'},
    {'z', 'x', 'c', 'v', 'b', 'n', 'm'}
}

local game_state = {}

function setup()
    init_game()
    draw_keyboard()
end

function init_game()
    game_state = {
        state = 'play',
        word = randchoice(spooky_words),
        guessed = {}, -- {"r", "s", "t", "l", "n", "e"},
        wrong = {},
        strikes = 0
    }
end

function reset()
    init_game()
end

function draw()
    draw_keyboard()
    draw_word()
    draw_guessed()
    draw_state()
end

function draw_state()
    local x = 200
    local y = 80
    graphics.setColor(1, 1, 1, 1)
    graphics.print(game_state.state, x, y)
    graphics.print(game_state.strikes .. ' strikes', x, y + 20)
    if game_state.state ~= 'play' then
        graphics.print('The word was ' .. game_state.word, x, y + 40)
        graphics.print('Tap anywhere or press space to play again', x, y + 60)
    end
end

function draw_word()
    x = 20
    y = 30
    s = 28
    p = 8

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
            graphics.setColor(1, 1, 1, 0.4)
            graphics.rectangle('line', x_, y_, s, s)
            local dc = '_'
            if reveal then
                dc = c
            end
            graphics.setColor(1, 1, 1, 1)
            graphics.print(dc, x_ + p / 2, y_ + p / 2)
        end
    end
end

function draw_guessed()
    local x = 80
    local y = 180
    local s = 30
    local p = 4
    for i = 1, #game_state.guessed do
        local x_ = x + (i - 1) * (s + p)
        local y_ = y
        graphics.setColor(1, 1, 1, 0.8)
        graphics.print(game_state.guessed[i], x_, y_)
    end
end

function render_keyboard(f)
    -- This function takes a callback function `f`
    -- that it calls for each letter on the keyboard
    -- once the layout position for it is computed.
    -- This way, we can use the same code/logic for
    -- drawing the keyboard and also handling touches

    local x = 20
    local y = 200
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
    -- log('letter pressed', letter)

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

            if is_game_won() then
                game_state.state = 'win'
            end

            break
        end
    end

    if not in_word then
        game_state.strikes = game_state.strikes + 1
        if game_state.strikes >= 5 then
            game_state.state = 'lose'
        end
    end
end

function is_game_won()
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
        if not guessed and ic ~= ' ' then
            return false
        end
    end

    -- Every letter in the word has been guessed; we win!
    return true
end

function mousepressed( x, y, button, istouch, presses )
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

function keypressed(key, scancode, isrepeat)
    if game_state.state ~= 'play' then
        if key == 'space' then
            reset_game()
        end
        return
    end

    if key >= 'a' and key <= 'z' and #key == 1 then
        guess_letter(key)
    end
end
