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

local data = Dialog("Raw Palette Loader")
:file {
  id = "palette_sprite",
  label = "Palette",
  title="Index Image",
  open=true,
}
:button{ id="confirm", text="Load Raw Palette" }
:show().data

if data.confirm then
  if not app.fs.isFile(data.palette_sprite) then return err("Palette not specified!") end
  
  local palette = imageToPalette(Image { fromFile = data.palette_sprite })
  if not palette then return err("Could not decode palette") end
  
  if not app.currentSprite then return err("No current sprite!") end
  
  app.currentSprite:setPalette(palette)
end