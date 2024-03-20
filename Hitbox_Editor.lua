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
        else
            result = result.."\""..v.."\""
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
    print(str)
end

function createHitBox()
    local sprite = app.sprite
    local newHitbox = sprite:newLayer()
    newHitbox.parent = hitboxGroup
    newHitbox.name = "New Hitbox"
    -- newHitbox.isContinuous = true -- use continuousness for iterpolating
    -- app.alert("A"..tostring(sprite).."B"..tostring(sprite.height))
    app.tool = 'rectangular_marquee'
    function fillBox(ev)
        -- local half = sprite.height/2
        -- selection:select(Rectangle{ x=half/2, y=half/2, width=half, height=half })
        -- app.command.MoveMask{ target='content', units='pixel', quantity=0 }
        local colorfg = app.fgColor
        app.fgColor = Color{r=255, g=0, b=0, a=64}
        app.command.Fill{ }
        app.fgColor = colorfg
        sprite.selection:deselect()
    end
    queueEvent('change', fillBox, (function() sprite.deleteLayer(newHitbox) end))
    -- app.useTool{tool='rectangular_marquee'}
end

-- Open dialog, ask user for two colors
function loadData()
    -- sprite.events:on('move',
    --     function(ev)
    --         print('The sprite has changed '..table_to_string(ev))
    --     end
    -- )
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
        dev(type.." Event: "..table_to_string(ev))
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
        menu = nil
     end)}:button{text="+",onclick=createHitBox}:show{wait=false}
end

do
    local hitboxData, hitboxGroup, menu
    eventQueue = { before=nil, after=nil, change=nil }
    loadData()
    createMenu()
end
