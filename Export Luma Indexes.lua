function err(message)
  app.alert { title = "Error", buttons = {"Ok"}, text = message }
end

-- generate the grayscale palette
local grayscalePalette = Palette(256)
for i=0, 255 do
  local newColor = Color { r=i, g=i, b=i, a=255 }
  grayscalePalette:setColor(i, newColor)
end

local data = Dialog("Export Luma-Indexed Image")
:file {
  id = "path",
  label = "Save indexes to path",
  title="Save Image as",
  save=true,
  filetypes={"png"},
}
:button{ id="confirm", text="Export" }
:show().data

if data.confirm then
  if not data.path then return err("No path selected!") end
  
  local image = app.activeImage
  
  if not image or image.colorMode ~= ColorMode.INDEXED then
    return err("no active indexed image!")
  end
  
  -- RGB image where we will write indices as colors
  local raw = Image(image.width, image.height, ColorMode.RGB)
  
  for i in image:pixels() do
    local pc = app.pixelColor
    
    local idx = i()
    local colorIdx = pc.rgba(idx, idx, idx)
    
    raw:drawPixel(i.x, i.y, colorIdx)
  end
  
  raw:saveAs(data.path)
end