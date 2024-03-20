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
    local selection = sprite.selection
    -- app.alert("A"..tostring(sprite).."B"..tostring(sprite.height))
    local half = sprite.width/2
    selection:select(Rectangle{ x=half/2, y=half/2, width=half, height=half })
    app.command.MoveMask{ target='content', units='pixel', quantity=0 }
    local colorfg = app.fgColor
    app.fgColor = Color{r=255, g=0, b=0, a=64}
    app.command.Fill{ }
    app.fgColor = colorfg
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

function createMenu()
    local dlg = Dialog("Hitbox Editor Toolbar")
    dlg
      :button{text="+",onclick=createHitBox}
      :show{wait=false}
end

-- Generates the color gradiants and displays them
-- Run script
do
    local hitboxData, hitboxGroup
    loadData()
    createMenu()
end
