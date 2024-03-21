-- Aseprite Script to open dialog to select hues between two colors
-- Written by aquova, 2018
-- https://github.com/aquova/aseprite-scripts

-- Convert a lua table into a lua syntactically correct string
function table_to_string(tbl)
    if not tbl then
        return '{ NIL }'
    end
    local result = "{"
    for k, v in pairs(tbl) do
        -- Check the key type (ignore any numerical keys - assume its an array)
        if type(k) == "string" then
            result = result..k.."="
        end
        -- Check the value type
        if type(v) == "table" then
            result = result..table_to_string(v)
        elseif type(v) == "boolean" then
            result = result..tostring(v)
        elseif type(v) == "function" then
            result = result..tostring(v)
        elseif type(v) == "string" then
            result = result.."\""..v.."\""
        elseif type(v) == "number" then
            result = result..v
        elseif type(v) == "userdata" then
            result = result..tostring(v)
        else
            result = result..type(v)..""
        end
        result = result..",\n"
    end
    -- Remove leading commas from the result
    if result ~= "{" then
        result = result:sub(1, result:len()-1)
    end
    return result.."}"
end

function dev(str)
    dev(str, 'info')
end

function dev(str, tag)
    if type(str) == "table" then
        str = table_to_string(str)
    end
    if tag == 'verbose' then
        -- print(str)
    elseif tag == 'error' then
        app.alert(str)
    else
        print(str)
    end
end

UTILS = {
drawRealImg=(function(ctx, SIZE)
    local sprite = app.sprite
    local img = Image(sprite.width, sprite.height, sprite.colorMode)
    img:drawSprite(sprite, app.site.frameNumber)
    ctx:drawImage(img,0,0,sprite.width,sprite.height,0,0,SIZE,SIZE)
end),
getSelection = (function(startPt,endPt,SIZE,coordsType)
    local x = math.min(startPt.x, endPt.x)
    local y = math.min(startPt.y, endPt.y)
    local w = math.abs(endPt.x - startPt.x)
    local h = math.abs(endPt.y - startPt.y)
    if coordsType == 'real' then
        return Rectangle{ x=x, y=y, width=w, height=h }
    end
    local sprite = app.sprite
    local drawScaleX = SIZE/sprite.width
    local drawScaleY = SIZE/sprite.height
    x=math.floor(x/drawScaleX)
    y=math.floor(y/drawScaleY)
    w=math.floor(w/drawScaleX)
    h=math.floor(h/drawScaleY)
    if coordsType == 'canvas' then
        return Rectangle{ x=x*drawScaleX, y=y*drawScaleY, width=w*drawScaleX, height=h*drawScaleY }
    elseif coordsType == 'sprite' then
        return Rectangle{ x=x, y=y, width=w, height=h }
    end
end),
openFile = (function(filepath)
    local configEnv = {}
    local f,err = loadfile(filepath, "t", configEnv)
    if f then
        f()
    end
    configEnv.filepath = filepath
    return configEnv
end),
closeFile = (function(fileToSave)
    local filepath = ''..fileToSave.filepath
    local f = io.open(filepath, "w")
    fileToSave.filepath = nil
    result = table_to_string(fileToSave)
    f:write(result:sub(2, result:len()-1))
    f:close()
    fileToSave.filepath = filepath
end),
}
function createHitBox()
    local dialog = Dialog("New Hitbox")
    local sprite = app.sprite
    local SIZE = 256
    local drawScaleX = SIZE/sprite.width
    local drawScaleY = SIZE/sprite.height
    local startPt = {x=(sprite.width/4)*drawScaleX, y=(sprite.height/4)*drawScaleY}
    local endPt = {x=(3*sprite.width/4)*drawScaleX, y=(3*sprite.height/4)*drawScaleY}
    local selecting = false    
    function fillBox(ev)
        local site = app.site
        local layer = app.activeLayer
        local newHitbox = sprite:newLayer()
        newHitbox.parent = hitboxGroup
        newHitbox.name = dialog.data.name
        hitboxGroup.isEditable = true
        -- newHitbox.isContinuous = true -- use continuousness for iterpolating
        sprite.selection:select(UTILS.getSelection(startPt,endPt,SIZE,'sprite'))
        local colorfg = app.fgColor
        app.fgColor = Color{r=dialog.data.color.red, g=dialog.data.color.green, b=dialog.data.color.blue, a=64}
        app.command.Fill{ }
        app.fgColor = colorfg
        sprite.selection:deselect()
        app.activeLayer = layer
        app.site = site
        hitboxGroup.isEditable = false
        dialog:close()
    end
    dialog:label{text="Hitbox name:"}:entry{id='name', text='Hitbox #'..(#hitboxGroup.layers+1), }:separator{}
    dialog:canvas{ id="canvas", width=SIZE, height=SIZE,
        onmousedown=(function(ev)
         startPt = {x=ev.x, y=ev.y}
         selecting = true
         dialog:repaint()
        end),
        onmousemove=(function(ev)
            if not selecting then return end
            endPt = {x=ev.x, y=ev.y}
            dialog:repaint()
        end),
        onmouseup=(function(ev)
            endPt = {x=ev.x, y=ev.y}
            selecting = false
            dialog:repaint()
        end),
        onpaint=(function(ev) 
            local ctx = ev.context
            UTILS.drawRealImg(ctx,SIZE)
            ctx.color = dialog.data.color
            ctx.color = Color{r=ctx.color.red, g=ctx.color.green, b=ctx.color.blue, a=64};
            ctx:fillRect(UTILS.getSelection(startPt,endPt,SIZE,'canvas'))
        end)
    }
    dialog:separator{}:label{text="Color:"}:color{ id='color',
    color=Color{r=255, g=0, b=0, a=255},
    onchange=(function(ev)dialog:repaint() end)}
    :separator()
    :button{ id="ok", text="ACCEPT", onclick=fillBox, focus=true }  
    :show{ wait=false }
end

function removeHitBox()
end
function editHitBox()
end

function toggleVisibility()
    local site = app.site
    local layer = app.activeLayer
    if hitboxGroup.isVisible then
        hitboxGroup.isCollapsed = true
        hitboxGroup.isVisible = false                    
        for i = 1,#hitboxGroup.layers do
            hitboxGroup.layers[i].isVisible = false
        end
        menu:modify{id='vis',text='—'}
        app.refresh()
    else            
        hitboxGroup.isVisible = true
        hitboxGroup.isExpanded = true                    
        for i = 1,#hitboxGroup.layers do
            hitboxGroup.layers[i].isVisible = true
        end
        menu:modify{id='vis',text='<o>'}
        app.refresh()
    end 
    app.activeLayer = layer
    app.site = site
end

function openSettings()
    local dialog = Dialog("Settings")
    function changeTab(ev)
        dialog:modify{id='sliderTest',visible=false}
        dialog:modify{id='comboTest',visible=false}
        dialog:modify{id='preserveOnClose',visible=false}
        dialog:modify{id='menuBtn',visible=false}
        dialog:modify{id='A',visible=false}
        dialog:modify{id='B',visible=false}
        dialog:modify{id='C',visible=false}
        dialog:modify{id='D',visible=false}
        dialog:modify{id='E',visible=false}
        if ev.tab == "hitbox" then
        elseif ev.tab == "general" then
            dialog:modify{id='preserveOnClose',visible=true}
        elseif ev.tab == "keybinds" then
        elseif ev.tab == "dev" then
            dialog:modify{id='sliderTest',visible=true}
            dialog:modify{id='comboTest',visible=true}
            dialog:modify{id='menuBtn',visible=true}
            dialog:modify{id='A',visible=true}
            dialog:modify{id='B',visible=true}
            dialog:modify{id='C',visible=true}
            dialog:modify{id='D',visible=true}
            dialog:modify{id='E',visible=true}
        end
    end
    dialog:tab{id="hitbox", text="Hitboxes"}
    dialog:tab{id="general", text="General"}
    dialog:tab{id="keybinds", text="Keybinds"}
    dialog:tab{id="dev", text="DevTesting"}
    dialog:endtabs{id='tabmenu',onchange=changeTab}
    dialog:check{id='preserveOnClose',text="Remove Hitboxes on Close", selected=not settings.preserveOnClose, onclick=function(ev) settings.preserveOnClose = not settings.preserveOnClose end}
    
    -- Dev Testing
    dialog:combobox{id='comboTest',options={"a","b","c"}, option='a'}
    dialog:slider{id='sliderTest', min=1, max=#app.sprite.frames,value=app.frame.frameNumber}
    dialog:button{id='menuBtn', text='menu',onclick=function(ev)
        menu = Dialog{title="Menu"}
        menu:menuItem{id='balh', text='Text A', onclick=noOP, selected=true}
        menu:menuItem{id='balh2', text='Text B', onclick=noOP}
        menu:showMenu{}
    end }
    dialog:newrow{ always=false }
    dialog:button{id='A',text="A"}
    dialog:button{id='B',text="B"}
    dialog:check{id='C',text="C"}
    dialog:button{id='D',text="D"}
    dialog:button{id='E',text="E"}
    dialog:modify{id='E', enabled=false}
    dialog:newrow{ always=true } 
    -- End Dev Testing
    
    dialog:separator{id='sep'}
    dialog:button{text="SAVE", onclick=function() dialog:close() end}
    changeTab({tab="hitbox"})
    dialog:show{wait=false}
end

function loadData()
    local sprite_data_path = app.fs.filePath(app.sprite.filename)..app.fs.pathSeparator..app.fs.fileTitle(app.sprite.filename)..'_HitboxData.lua'
    local sprite_data = UTILS.openFile(sprite_data_path)
    
    local site = app.site
    local layer = app.activeLayer
    hitboxData = {}
    hitboxGroup = nil
    local sprite = app.sprite
    for i,layer in ipairs(sprite.layers) do
        if layer.name == "Hitboxes" and layer.isGroup then
            hitboxGroup = layer
            -- dev('Found it!')
            break
        end
    end
    if not hitboxGroup then
        hitboxGroup = sprite:newGroup();
        hitboxGroup.name = 'Hitboxes';
        -- dev('created group')
    end
    hitboxGroup.isEditable = false
    for i,layer in ipairs(hitboxGroup.layers) do
        hitboxData[layer.name] = layer
    end
    
    app.activeLayer = layer
    app.site = site
    app.refresh()
end

function noOP()
end

function createMenu()
    if menu then
        menu:close()
    end
    loadData()
    menu = Dialog{title="Hitbox Toolbar", onclose=(function()
        if not settings.preserveOnClose then
            app.sprite:deleteLayer(hitboxGroup)
        end
        UTILS.closeFile(settings)
        menu = nil
     end)}
    :button{text="◻+",onclick=createHitBox}
    :button{text='◻-',onclick=removeHitBox}
    :button{text="◻?",onclick=editHitBox}
    :button{id='vis',text='<o>',onclick=toggleVisibility}
    :button{text='...',onclick=openSettings}:show{wait=false}
end

local hitboxData, hitboxGroup, menu
local script_path = app.fs.userConfigPath..'scripts'..app.fs.pathSeparator..'Hitbox_Editor'
local settings_path = script_path..app.fs.pathSeparator..'Hitbox_Settings.ini'
settings = UTILS.openFile(settings_path)
createMenu()
