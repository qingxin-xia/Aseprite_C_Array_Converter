if app.apiVersion < 1 then
    return app.alert("This script requires at least Aseprite v1.2.10-beta3")
end

local sprite = app.activeSprite
if sprite == nil then
    app.alert("Open a sprite first!")
    return
elseif sprite.colorMode ~= ColorMode.INDEXED then
    app.alert("Current sprite is not in indexed mode.")
    return
end

local baseName = string.gsub(sprite.filename, "%.[^.]+$", "") -- Remove extension
-- Clear the file instantly by opening it briefly in "w" mode and closing it
io.open(baseName .. ".c", "w"):close()

-- Open File ('a' for append)
local file = io.open(baseName .. ".c", "a")

file:write('#include <cstdint>\n')

-- Palette
local palette = sprite.palettes[1]
if palette == nil then
    app.alert("No palette found in the sprite.")
    return
end
if #palette > 256 then
    app.alert("Palette has more than 256 colors. Please reduce the palette size.")
    return
end
output = "const uint16_t palette[" .. #palette .. "] = {\n    "
file:write(output)
for i = 0,#palette-1 do
    local color = palette:getColor(i)
    -- Format as hex values 565 RGB
    Rgb565 = (((color.red & 0xf8)<<8) + ((color.green & 0xfc)<<3) + (color.blue>>3))
    output = string.format("0x%04X, ", Rgb565)
    file:write(output)
    if (i + 1) % 6 == 0 then file:write("\n    ") end
end
file:write("\n};\n\n")


-- Frame duration (ms)
file:write(string.format("const uint16_t frame_durations[%d] = {\n    ", #sprite.frames))
for i = 1, #sprite.frames do
    local frame = sprite.frames[i]
    
    -- frame.duration is in seconds (e.g., 0.05), add 0.5 for floating point errors
    local duration_ms = math.floor((frame.duration * 1000) + 0.5)
    
    file:write(string.format("%d", duration_ms))
    
    -- Format trailing commas clean
    if i < #sprite.frames then
        file:write(", ")
    end
    if i % 10 == 0 and i < #sprite.frames then
        file:write("\n    ")
    end
end

file:write("\n};\n\n")


-- Frames
output = "const int FRAME_WIDTH = " .. sprite.width .. ";\nconst int FRAME_HEIGHT = " .. sprite.height .. ";\n\n"
file:write(output)


output = "const uint8_t animation[" .. #sprite.frames .. "][" .. sprite.height * sprite.width .. "] = {\n    "
file:write(output)
for i = 1, #sprite.frames do
    local frame = sprite.frames[i]
    file:write("{\n        ")
    -- Generate a temporary flat image for this specific frame
    local img = Image(sprite.width, sprite.height, sprite.colorMode)
    img:drawSprite(sprite, frame)
    
    for y = 0, sprite.height - 1 do
        for x = 0, sprite.width - 1 do
            local pixelValue = img:getPixel(x, y) -- Grabs the palette index directly
            file:write(string.format("0x%02X, ", pixelValue))
        end
        file:write("\n        ")
    end
    file:write("\n    },\n\n")
end
file:write("}; \n\n")


-- Save out the final file
file:close()


output = "#ifndef ANIMATION_H\n#define ANIMATION_H\n#include <stdint.h>\nextern const uint8_t animation[" .. #sprite.frames .. "][" .. sprite.height .. "][" .. sprite.width .. "];\nextern const uint32_t palette[".. #palette .."];\nextern const uint16_t frame_durations[".. #sprite.frames .. "];\nextern const int FRAME_WIDTH;\nextern const int FRAME_HEIGHT;\n#endif\n"
local fileH = io.open(baseName .. ".h", "w")
fileH:write(output)
fileH:close()
app.alert("Exported array code to " .. baseName .. ".h/.c")