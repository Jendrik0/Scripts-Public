--[[ Endless Strip Mining Turtle ]]
-- Reserved slots: 15 - Coal, 16 - Ender Chest

-- Basic configuration
local CHEST_SLOT = 16
local FUEL_SLOT = 15
local MIN_FUEL = 500  -- Minimum fuel level before refueling
local STRIP_WIDTH = 3  -- Number of blocks between strip lanes

-- Initial setup
turtle.select(1)
local isGoingRight = true
local currentLane = 0

-- Function to check important slots
function checkSpecialSlots()
    if turtle.getItemCount(CHEST_SLOT) == 0 then
        print("Ender chest missing in slot "..CHEST_SLOT)
        error("Missing Ender Chest", 0)
    end
end

-- Modified refuel function
function refuel()
    turtle.select(FUEL_SLOT)
    while turtle.getFuelLevel() < MIN_FUEL do
        if turtle.getItemCount(FUEL_SLOT) == 0 then
            print("Need more fuel in slot "..FUEL_SLOT)
            error("Out of fuel", 0)
        end
        turtle.refuel(1)
    end
    turtle.select(1)
end

-- Improved inventory management
function shouldEmpty()
    local used = 0
    for i=1,14 do  -- Only check regular slots
        if turtle.getItemCount(i) > 0 then used = used + 1 end
    end
    return used >= 14  -- Keep 2 slots free
end

function emptyInventory()
    turtle.select(CHEST_SLOT)
    turtle.placeUp()  -- Place ender chest above
    for i=1,14 do
        turtle.select(i)
        turtle.dropUp()
    end
    turtle.select(CHEST_SLOT)
    turtle.digUp()
    turtle.select(1)
end

-- Mining functions
function mineColumn()
    -- Mine down to bedrock
    while turtle.digDown() do
        turtle.down()
        if turtle.detectDown() then
            turtle.digDown()
        else
            break  -- Bedrock reached
        end
    end
    
    -- Return to original height
    while not turtle.detectUp() do
        turtle.up()
    end
end

function moveForward()
    while not turtle.forward() do
        turtle.dig()
        sleep(0.5)
    end
end

-- Main mining pattern
function mineStrip()
    while true do
        checkSpecialSlots()
        refuel()
        
        -- Mine current block column
        mineColumn()
        
        -- Move forward and prepare next column
        moveForward()
        turtle.digUp()
        
        -- Check inventory every 16 blocks
        if math.fmod(currentLane, 16) == 0 and shouldEmpty() then
            emptyInventory()
        end
        
        -- Switch direction when strip width reached
        if currentLane >= STRIP_WIDTH then
            -- Turn around
            turtle.turnRight()
            turtle.turnRight()
            
            -- Move to next strip level
            for i=1,STRIP_WIDTH do
                moveForward()
            end
            turtle.turnRight()
            moveForward()
            turtle.turnRight()
            
            currentLane = 0
        else
            currentLane = currentLane + 1
        end
    end
end

-- Start mining
print("Starting endless strip mining...")
mineStrip()
