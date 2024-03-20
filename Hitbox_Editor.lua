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
            result = result.."[\""..k.."\"]".."="
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
        result = result..","
    end
    -- Remove leading commas from the result
    if result ~= "" then
        result = result:sub(1, result:len()-1)
    end
    return result.."}"
end

function dev(str)
    dev(str, 'info')
end

function dev(str, tag)
    -- if type(str) == "table" then
        -- str = ''..table_to_string(str)
    -- end
    if tag == 'verbose' then
        -- print(str)
    elseif tag == 'error' then
        app.alert(str)
    else
        print(str)
    end
end

function createHitBox()
    local dialog = Dialog("New Hitbox")
    local sprite = app.sprite
    local SIZE = 256
    local drawScaleX = SIZE/sprite.width
    local drawScaleY = SIZE/sprite.height
    local startPt = {x=(sprite.width/4)*drawScaleX, y=(sprite.height/4)*drawScaleY}
    local endPt = {x=(3*sprite.width/4)*drawScaleX, y=(3*sprite.height/4)*drawScaleY}
    local selecting = false
    function getSelection(coordsType)
        local x = math.min(startPt.x, endPt.x)
        local y = math.min(startPt.y, endPt.y)
        local w = math.abs(endPt.x - startPt.x)
        local h = math.abs(endPt.y - startPt.y)
        if coordsType == 'real' then
            return Rectangle{ x=x, y=y, width=w, height=h }
        end
        x=math.floor(x/drawScaleX)
        y=math.floor(y/drawScaleY)
        w=math.floor(w/drawScaleX)
        h=math.floor(h/drawScaleY)
        if coordsType == 'canvas' then
            return Rectangle{ x=x*drawScaleX, y=y*drawScaleY, width=w*drawScaleX, height=h*drawScaleY }
        elseif coordsType == 'sprite' then
            return Rectangle{ x=x, y=y, width=w, height=h }
        end
    end
    function fillBox(ev)
        local site = app.site
        local layer = app.activeLayer
        local newHitbox = sprite:newLayer()
        newHitbox.parent = hitboxGroup
        newHitbox.name = dialog.data.name
        -- newHitbox.isContinuous = true -- use continuousness for iterpolating
        sprite.selection:select(getSelection('sprite'))
        local colorfg = app.fgColor
        app.fgColor = Color{r=dialog.data.color.red, g=dialog.data.color.green, b=dialog.data.color.blue, a=64}
        app.command.Fill{ }
        app.fgColor = colorfg
        sprite.selection:deselect()
        app.site = site
        app.activeLayer = layer
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
            local sprite = app.sprite
            local img = Image(sprite.width, sprite.height, sprite.colorMode)
            img:drawSprite(sprite, app.site.frameNumber)
            ctx:drawImage(img,0,0,sprite.width,sprite.height,0,0,SIZE,SIZE)
            ctx.color = dialog.data.color
            ctx.color = Color{r=ctx.color.red, g=ctx.color.green, b=ctx.color.blue, a=64};
            ctx:fillRect(getSelection('canvas'))
        end)
    }
    dialog:separator{}:label{text="Color:"}:color{ id='color',
    color=Color{r=255, g=0, b=0, a=255},
    onchange=(function(ev)dialog:repaint() end)}
    :separator()
    :button{ id="ok", text="ACCEPT", onclick=fillBox }
    :show{ wait=false }
end

-- Open dialog, ask user for two colors
function loadData()
    -- sprite.events:on('move',
    --     function(ev)
    --         print('The sprite has changed '..table_to_string(ev))
    --     end
    -- )
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
    
    for i,layer in ipairs(hitboxGroup.layers) do
        hitboxData[layer.name] = layer
    end
    
    app.site = site
    app.activeLayer = layer
    -- app.alert("Selection: "..tostring(selection.bounds))
    -- app.editor:askPoint{
    --     title='wow',
    --     onclick=function(ev)
    --         print(tostring(ev.x).." "..tostring(ev.y).." "..tostring(event))
    --     end
    -- }
end
function noOP()
end
function queueEvent(event, callback)
    queueEvent(event, callback, noOP)
end
function queueEvent(event, callback, cancel)
    if eventQueue[event] then
        eventQueue[event].cancel()
    end
    eventQueue[event] = {callback=callback, cancel=cancel}
end

function createMenu()
    if menu then
        menu.close()
    end
    local function listener(type, ev)
        if eventQueue[type] then
            eventQueue[type].callback(ev)
            eventQueue[type] = nil
        end
        dev(type.." Event: "..table_to_string(ev), 'verbose')
    end
    local function beforelistener(ev)
        listener('before', ev)
    end
    local function afterlistener(ev)
        listener('after', ev)
    end
    local function changelistener(ev)
        listener('change', ev)
    end
    local sprite = app.sprite
    app.events:on('beforecommand', beforelistener)
    sprite.events:on('change', changelistener)
    app.events:on('aftercommand', afterlistener)
    menu = Dialog{title="Hitbox Editor Toolbar", onclose=(function() 
        app.events:off(beforelistener)
        sprite.events:off(changelistener)
        app.events:off(afterlistener)
        sprite:deleteLayer(hitboxGroup)
        menu = nil
     end)}:button{text="+",onclick=createHitBox}:show{wait=false}
end

do
    local hitboxData, hitboxGroup, menu
    eventQueue = { before=nil, after=nil, change=nil }
    loadData()
    createMenu()
end
