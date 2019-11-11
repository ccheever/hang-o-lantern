local Object = require 'classic'

local SpriteSheet = Object:extend()

function SpriteSheet:new(img, spriteWidth, spriteHeight)
    if type(img) == 'string' then
        self._spriteSheetImage = love.graphics.newImage(img)
    else
        self._spriteSheetImage = img
    end
    self._spriteWidth = spriteWidth
    self._spriteHeight = spriteHeight
    self._width, self._height = self._spriteSheetImage:getDimensions()
    self._numColumns = math.floor(self._width / self._spriteWidth)
end

function SpriteSheet:draw(sprite, x, y, flipHorizontal, flipVertical, rotation)
    local col, row = (sprite - 1) % self._numColumns, math.floor((sprite - 1) / self._numColumns)
    love.graphics.draw(
        self._spriteSheetImage,
        love.graphics.newQuad(
            self._spriteWidth * col,
            self._spriteHeight * row,
            self._spriteWidth,
            self._spriteHeight,
            self._width,
            self._height
        ),
        x + self._spriteWidth / 2,
        y + self._spriteHeight / 2,
        rotation or 0,
        flipHorizontal and -1 or 1,
        flipVertical and -1 or 1,
        self._spriteWidth / 2,
        self._spriteHeight / 2
    )
end

-- Draws a sprite from a sprite sheet, spriteNum=1 is the upper-leftmost sprite
function drawSprite(spriteSheetImage, spriteWidth, spriteHeight, sprite, x, y, flipHorizontal, flipVertical, rotation)
    local width, height = spriteSheetImage:getDimensions()
    local numColumns = math.floor(width / spriteWidth)
    local col, row = (sprite - 1) % numColumns, math.floor((sprite - 1) / numColumns)
    love.graphics.draw(
        spriteSheetImage,
        love.graphics.newQuad(spriteWidth * col, spriteHeight * row, spriteWidth, spriteHeight, width, height),
        x + spriteWidth / 2,
        y + spriteHeight / 2,
        rotation or 0,
        flipHorizontal and -1 or 1,
        flipVertical and -1 or 1,
        spriteWidth / 2,
        spriteHeight / 2
    )
end

return {
    drawSprite = drawSprite,
    SpriteSheet = SpriteSheet
}
