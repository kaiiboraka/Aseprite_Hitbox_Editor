-- Aseprite Script to create hitboxes
-- Written by kaiiboraka and code_addict, 2024 
-- https://github.com/kaiiboraka/

-- Run script
do
    local sprite = app.editor.sprite
    local selection = sprite.selection
    local half = sprite.width/2
    -- app.alert("A"..tostring(sprite).."B"..tostring(sprite.height))
    selection:select(Rectangle{ x=half/2, y=half/2, width=half, height=half })
    app.command.MoveMask{ target='content', units='pixel', quantity=0 }
    local colorfg = app.fgColor
    app.fgColor = Color{r=255, g=0, b=0, a=128}
    app.command.Fill()
    app.fgColor = colorfg
end
