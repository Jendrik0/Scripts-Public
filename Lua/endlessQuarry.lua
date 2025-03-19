--[[ Endless Strip Mining Turtle ]]
-- Reserved slots: 15 - Coal, 16 - Ender Chest

-- Basic configuration
local CHEST_SLOT = 16
local FUEL_SLOT = 15
local MIN_FUEL = 500  -- Minimum fuel level before refueling
local STRIP_WIDTH = 3  -- Blocks between strip lanes

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

-- Improved refuel function
function refuel()
    turtle.select(FUEL_SLOT)
    while turtle.getFuelLevel() < MIN_FUEL do
        if turtle.getItemCount(FUEL_SLOT) == 0 then
            print("Need more fuel in slot "..FUEL_SLOT)
            error("Out of fuel", 0)
        end
        local needed = math.ceil((MIN_FUEL - turtle.getFuelLevel()) / 80)
        turtle.refuel(math.min(needed, turtle.getItemCount(FUEL_SLOT)))
    end
    turtle.select(1)
end

-- Inventory management with 2 free slots
function shouldEmpty()
    local used = 0
    for i=1,14 do
        if turtle.getItemCount(i) > 0 then used = used + 1 end
    end
    return used >= 12  -- Keep 2 slots free
end

function emptyInventory()
    turtle.select(CHEST_SLOT)
    turtle.placeUp()
    for i=1,14 do
        turtle.select(i)
        turtle.dropUp()
    end
    turtle.select(CHEST_SLOT)
    turtle.digUp()
    turtle.select(1)
end

-- Proper column mining with depth tracking
function mineColumn()
    local depth = 0
    while turtle.digDown() do
        turtle.down()
        depth = depth + 1
    end
    -- Return to original height
    for i=1,depth do
        turtle.up()
    end
end

-- Forward movement with digging
function moveForward()
    while not turtle.forward() do
        turtle.dig()
        sleep(0.5)
    end
end

-- Corrected strip mining pattern
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
        if currentLane % 16 == 0 and shouldEmpty() then
            emptyInventory()
        end
        
        -- Handle strip width spacing
        if currentLane >= STRIP_WIDTH then
            -- Turn around and return to start
            turtle.turnRight()
            turtle.turnRight()
            for i=1,STRIP_WIDTH do
                moveForward()
            end
            
            -- Move to next strip with proper spacing
            turtle.turnRight()
            for i=1,STRIP_WIDTH do
                moveForward()
            end
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
