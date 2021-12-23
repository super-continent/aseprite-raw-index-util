-- basic stuff
function err(message)
  app.alert { title = "Error", buttons = {"Ok"}, text = message }
end

-- generate the grayscale palette
local grayscalePalette = Palette(256)
for i=0, 255 do
  local newColor = Color { r=i, g=i, b=i }
  grayscalePalette:setColor(i, newColor)
end

-- image to palette direct-conversion:
-- aseprite normally has some implicit behaviors
-- around loading palettes, organizing their colors, etc.
-- i use this to keep the indexes the same as what
-- BBCF actually uses in-game
function imageToPalette(image)
  if (image.colorMode ~= ColorMode.RGB) or (image.width * image.height) > 256 then 
    return nil
  end

  local pc = app.pixelColor

  local palette = Palette(256)
  local idx = 0
  for i in image:pixels() do
    local p = i()
    local red = pc.rgbaR(p)
    local green = pc.rgbaG(p)
    local blue = pc.rgbaB(p)
    local alpha = pc.rgbaA(p)

    local color = Color { r=red, g=green, b=blue, a=alpha }
    palette:setColor(idx, color)
    
    idx = idx + 1
  end

  return palette
end

local data = Dialog("Luma-Indexed Image Loader")
:file {
  id = "image",
  label = "Indexed Image",
  title="Index Image",
  open=true,
  filetypes={"png"},
}
:file {
  id = "palette_sprite",
  label = "Palette",
  title="Index Image",
  open=true,
  filetypes={"png"},
}
:button{ id="confirm", text="Load Indexed Image" }
:show().data

if data.confirm then
  if not app.fs.isFile(data.image) then return err("Image not specified!") end
  if not app.fs.isFile(data.palette_sprite) then return err("Palette not specified!") end

  local sprite = app.open(data.image)
  if not sprite then return err("Could not load image") end
  
  local palette = imageToPalette(Image { fromFile = data.palette_sprite })
  if not palette then return err("Could not decode palette") end
  
  -- set palette to grayscale then convert image to indexed mode.
  -- this preserves the indices so they arent lost to the new palette
  sprite:setPalette(grayscalePalette)
  app.command.ChangePixelFormat{format="indexed"}
  
  sprite:setPalette(palette)
end