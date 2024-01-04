require"/files/button"

local BUTTON_HEIGHT = 64


local buttons = {}
local pauseButtons = {}
local font = nil
local STATE_GAMEPLAY = 1
local STATE_MAIN_MENU = 0
local state = STATE_MAIN_MENU
local changed = false


function loadMainMenu()
    font = love.graphics.newFont(32)
    table.insert(buttons, newButton("Start Game", startGame))
    table.insert(buttons, newButton("Exit", exit))
    table.insert(pauseButtons, newButton("Resume", resume))
    table.insert(pauseButtons, newButton("Main Menu", menu))
end


function updateState(current)
    if changed == false then
        return current
    else 
        changed = false
        return state
    end
end

function drawMainMenu()
    local ww = love.graphics.getWidth()
    local wh = love.graphics.getHeight()
    local button_width = ww * (1/3)
    local margin = 16
    local total_height = (BUTTON_HEIGHT + margin) * #buttons
    local cursor_y = 0
    for i, button in ipairs(buttons) do
        button.last = button.now
        local bx = (ww * 0.5) - (button_width * 0.5)
        local by = (wh * 0.5) - (total_height * 0.5) + cursor_y
        local color = {0.4, 0.4, 0.5, 1.0}
        local mx, my = love.mouse.getPosition()
        local hot = mx > bx and mx < bx + button_width and my > by and my < by + BUTTON_HEIGHT
        if hot then
            color = {0.8, 0.8, 0.9, 1.0}
        end
        button.now = love.mouse.isDown(1)
        if button.now and not button.last and hot then
         button.fn()
        end
        love.graphics.setColor(unpack(color))
        love.graphics.rectangle("fill", bx,by, button_width, BUTTON_HEIGHT)

        love.graphics.setColor(0, 0, 0, 1)
        local textw = font:getWidth(button.text)
            texth = font:getHeight(button.text)
        love.graphics.print(button.text, font,(ww * 0.5) - textw * 0.5, by + texth * 0.5)
        cursor_y = cursor_y + (BUTTON_HEIGHT + margin)
    end
end

function drawPauseMenu()
    local ww = love.graphics.getWidth()
    local wh = love.graphics.getHeight()
    love.graphics.setColor(0, 0, 0, 0.4)
    love.graphics.rectangle("fill", 0, 0, ww, wh)

    -- Reset color to default
    love.graphics.setColor(1, 1, 1)
    local button_width = ww * (1/3)
    local margin = 16
    local total_height = (BUTTON_HEIGHT + margin) * #buttons
    local cursor_y = 0
    for i, button in ipairs(pauseButtons) do
        button.last = button.now
        local bx = (ww * 0.5) - (button_width * 0.5)
        local by = (wh * 0.5) - (total_height * 0.5) + cursor_y
        local color = {0.4, 0.4, 0.5, 1.0}
        local mx, my = love.mouse.getPosition()
        local hot = mx > bx and mx < bx + button_width and my > by and my < by + BUTTON_HEIGHT
        if hot then
            color = {0.8, 0.8, 0.9, 1.0}
        end
        button.now = love.mouse.isDown(1)
        if button.now and not button.last and hot then
         button.fn()
        end
        love.graphics.setColor(unpack(color))
        love.graphics.rectangle("fill", bx,by, button_width, BUTTON_HEIGHT)

        love.graphics.setColor(0, 0, 0, 1)
        local textw = font:getWidth(button.text)
            texth = font:getHeight(button.text)
        love.graphics.print(button.text, font,(ww * 0.5) - textw * 0.5, by + texth * 0.5)
        cursor_y = cursor_y + (BUTTON_HEIGHT + margin)
    end
end


function startGame()
    state = STATE_GAMEPLAY
    changed = true

end

function exit()
    love.event.quit()
end



function resume()
    state = STATE_GAMEPLAY
    changed = true

 
 end
 
 function menu()
     state = STATE_MAIN_MENU
     changed = true

 end
