-- ============= Written by Freac212 - 03 24 21 =============
-- This script is for a mining turtle (From ComputerCraft Tweaked in Minecraft) to mine a specified grid of blocks XYZ.
-- See readme for more instructions.
-- ==========================================================

-- Constants
local column = 5  -- Default 25 Y - Left/Right
local row = 5     -- Default 25 X - Forward/ Backward
local height = 20 -- Default 10 Z Currently is double the count! so 3 height = 6!
--[[
  S = Starting position of the turtle
    Y  Y  Y
  X[ ][ ][ ]
  X[ ][ ][ ]
  X[S][ ][ ]
]]--
local dNORTH = {
  isNorth=true,
  isEast=false,
  isSouth=false,
  isWest=false
}
local dSOUTH = {
  isNorth=false,
  isEast=false,
  isSouth=true,
  isWest=false
}
local dEAST = {
  isNorth=false,
  isEast=true,
  isSouth=false,
  isWest=false
}
local dWEST = {
  isNorth=false,
  isEast=false,
  isSouth=false,
  isWest=true
}


-- Tool Functions
function table.shallow_copy(t)
  local t2 = {}
  for k,v in pairs(t) do
    t2[k] = v
  end
  return t2
end

local function directionToString(direction)
  if direction.isNorth then
    return "North"
  elseif direction.isSouth then
    return "South"
  elseif direction.isEast then
    return "East"
  elseif direction.isWest then
    return "West"
  else
    error("Could not convert direction to string.")
  end
end

local function boolToString(bool)
  if bool then
    return "T"
  else 
    return "F"
  end
end

local function getUpdatedDirection(direction, isTurningLeft)
  -- if not turning left then must be turning right!
  -- This is not the greatest way to track direction but it does the job.
  local tempDirection = {
    isNorth=false,
    isEast=false,
    isSouth=false,
    isWest=false
  }

  if direction.isNorth then
    if isTurningLeft then
      tempDirection.isWest = true
    else 
      tempDirection.isEast = true
    end
  elseif direction.isEast then
    if isTurningLeft then
      tempDirection.isNorth = true
    else 
      tempDirection.isSouth = true
    end
  elseif direction.isSouth then
    if isTurningLeft then
      tempDirection.isEast = true
    else 
      tempDirection.isWest = true
    end
  elseif direction.isWest then
    if isTurningLeft then
      tempDirection.isSouth = true
    else 
      tempDirection.isNorth = true
    end
  end

  return tempDirection
end

local function getCurrentCoordinates()
  return vector.new(gps.locate(5))
end

local function digUp()
  while turtle.detectUp() do
    turtle.digUp()
  end
end

local function digAndMoveForward()
  while turtle.detect() do
    turtle.dig()
  end
  digUp()
  turtle.forward()
  digUp()
end

-- Main Program
local vHomeLocation = getCurrentCoordinates()
local turtleTracking = {
  direction = {
    isNorth=false,
    isEast=false,
    isSouth=false,
    isWest=false
  },
  determineInitialDirection = function (self)
    xA, yA, zA = gps.locate(5)
    digAndMoveForward()
    -- vComparativeCoordinates = getCurrentCoordinates()
    xB, yB, zB = gps.locate(5)
    turtle.back()

    if(zA > zB) then 
      --Facing North
      self.direction.isNorth = true
    elseif(zA < zB) then
      --Facing South
      self.direction.isSouth = true
    elseif(xA > xB) then
      --Facing West
      self.direction.isWest = true
    elseif(xA < xB) then
      --Facing East
      self.direction.isEast = true
    else
      error("Could not determine north, not sure how that is possible, maybe GPS connection issues.")
    end

  end,
  turnLeft = function (self)
    turtle.turnLeft()
    temp = getUpdatedDirection(self.direction, true)
    self.direction.isNorth = temp.isNorth
    self.direction.isEast = temp.isEast
    self.direction.isSouth = temp.isSouth
    self.direction.isWest = temp.isWest
  end,
  turnRight = function (self)
    turtle.turnRight()
    temp = getUpdatedDirection(self.direction, false)
    self.direction.isNorth = temp.isNorth
    self.direction.isEast = temp.isEast
    self.direction.isSouth = temp.isSouth
    self.direction.isWest = temp.isWest
  end,
  turnTo = function (self, directionToLook)
    -- Oh boy...
    if directionToLook.isNorth then
      if self.direction.isEast then
        self:turnLeft()
      elseif self.direction.isSouth then
        self:turnLeft()
        self:turnLeft()
      elseif self.direction.isWest then
        self:turnRight()
      end

    elseif directionToLook.isEast then
      if self.direction.isNorth then
        self:turnRight()
      elseif self.direction.isSouth then
        self:turnLeft()
      elseif self.direction.isWest then
        self:turnLeft()
        self:turnLeft()
      end

    elseif directionToLook.isSouth then
      if self.direction.isNorth then
        self:turnLeft()
        self:turnLeft()
      elseif self.direction.isEast then
        self:turnRight()
      elseif self.direction.isWest then
        self:turnLeft()
      end

    elseif directionToLook.isWest then
      if self.direction.isNorth then
        self:turnLeft()
      elseif self.direction.isEast then
        self:turnLeft()
        self:turnLeft()
      elseif self.direction.isSouth then
        self:turnRight()
      end
    end
  end,
  getCurrentDirection = function(self)
    return directionToString(self.direction)
  end
}

local function digDownMoveDownAndTurnAround(digDownAmount)
  for z=1, digDownAmount do 
    while turtle.detectDown() do
      turtle.digDown()
    end
    turtle.down()
  end
  -- Turn the bot around 180 
  turtleTracking:turnLeft()
  turtleTracking:turnLeft()
end

local function finishWork()
  -- Paaarrtaaaay!
  for i=1, 4 do
    turtleTracking:turnRight()
  end
end

hasTurnedRight = false
local function endOfRowMovement(yColumnCount)
  -- Could update this in the future to use compass directions to determine whether to turn right or left
  -- instead of this holding state of 'turnedRight', it does currently work fine though.
  if hasTurnedRight then
    turtleTracking:turnLeft()
    digAndMoveForward()
    turtleTracking:turnLeft()
    hasTurnedRight = false
  else
    turtleTracking:turnRight()
    digAndMoveForward()
    turtleTracking:turnRight()
    hasTurnedRight = true
  end
end

local function testTurnTo()
  print("Press enter to start 'turnTo' tests...")
  input = read()

  term.clear()
  term.setCursorPos(1, 1)
  turtleTracking:turnTo(dEAST)
  print("Direction according to the turtle: "..turtleTracking:getCurrentDirection())
  print("Press enter to confirm is facing EAST")
  input = read()
  turtleTracking:turnTo(dSOUTH)
  print("Direction according to the turtle: "..turtleTracking:getCurrentDirection())
  print("Press enter to confirm is facing SOUTH")
  input = read()
  turtleTracking:turnTo(dWEST)
  print("Direction according to the turtle: "..turtleTracking:getCurrentDirection())
  print("Press enter to confirm is facing WEST")
  input = read()
  turtleTracking:turnTo(dNORTH)
  print("Direction according to the turtle: "..turtleTracking:getCurrentDirection())
  print("Press enter to confirm is facing NORTH")
  input = read()
end

local function navigateTo(vLocation)
  local vCurrentPos = getCurrentCoordinates()

  local vDifferenceOfPositions = vLocation:sub(vCurrentPos)
  -- print("Difference X Y Z: ", vDifferenceOfPositions.x, vDifferenceOfPositions.y, vDifferenceOfPositions.z)

  -- print("Verify diff..")
  -- read()
  --  Rounding to remove 0.999999999999 locations, even though that may not be possible for the bot as it only deals in whole coordinates.
  local diffX = math.floor(vDifferenceOfPositions.x)
  local diffY = math.floor(vDifferenceOfPositions.y)
  local diffZ = math.floor(vDifferenceOfPositions.z)

  -- Doing Y first to hopefully avoid more mining if the bot had to move to the position underhome and there was unmined blocks.
  -- Hopefully by going up to already mined areas then moving X + Z.
  if(diffY < 0)then
    -- No need to turn..
    while diffY < 0 do
      diffY = diffY + 1
      turtle.down()
    end
  elseif(diffY > 0)then
    -- No need to turn..
    -- Also in like 99.9% of cases the turtle will never be above the home coordinates.
    while diffY > 0 do
      diffY = diffY - 1
      turtle.up()
    end
  end

  if(diffX < 0)then
    turtleTracking:turnTo(dWEST)
    while diffX < 0 do
      diffX = diffX + 1
      digAndMoveForward()
    end
  elseif(diffX > 0)then
    turtleTracking:turnTo(dEAST)
    while diffX > 0 do
      diffX = diffX - 1
      digAndMoveForward()
    end
  end

  if(diffZ < 0)then
    turtleTracking:turnTo(dNORTH)
    while diffZ < 0 do
      diffZ = diffZ + 1
      digAndMoveForward()
    end
  elseif(diffZ > 0)then
    turtleTracking:turnTo(dSOUTH)
    while diffZ > 0 do
      diffZ = diffZ - 1
      digAndMoveForward()
    end
  end
end

local function checkForChest()
  for i = 1, 5 do
    -- turns 5 times, even though 4 would likely suffice checking for a chest
    local check, infront = turtle.inspect() --# will get the block name and the metadata
    if infront == nil or infront.name == nil then
      turtleTracking:turnLeft()
    else
      local i, j = string.find(infront.name, "chest")
      if not (i == nil) then
        break
      else
        turtleTracking:turnLeft()
      end
    end

    if(i == 5) then
      print("Please place a chest near the bot and press enter when ready.")
      read()
      checkForChest() -- Recursive functions.. WEEEEE!!
    else 
      i = i + 1
    end
  end
end

turtle.refuel()
print("Refueled turtle!")

if vHomeLocation.x == nil then
  error("Could not acquire current location. Perhaps there's no wireless modem attached or we're out of range of any GPS hosts.")
else
  print("Current location is: ", vHomeLocation.x, vHomeLocation.y, vHomeLocation.z)
end

turtleTracking:determineInitialDirection()

-- Testing
-- print("Press enter to allow turtle to determine it's facing direction..")
-- local input = read()
--print("Current direction is: "..turtleTracking:getCurrentDirection())
-- testTurnTo()

print("Press enter to start mining op.")
input = read()
term.clear()
term.setCursorPos(1, 1)

for z=1, height do -- Z Axis
  -- print("Vertical Z: "..z)
  for y=1, column do  -- Y Columns
    turtle.refuel()
    -- print("Column Y: "..y)
    -- Check everytime a row is done if the turtle needs to refuel

    for x=1, row do -- X Rows
      -- print("Row X: "..x)
      term.clear()
      term.setCursorPos(1, 1) 
      print("Fuel level: "..turtle.getFuelLevel())

      local isEmptySlotInInventory = false

      for i=1, 16 do 
        if turtle.getItemCount(i) == 0 then
          -- If there's a slot that has an item count of 0, continue, else
          isEmptySlotInInventory = true
        end
      end

      if not isEmptySlotInInventory then
        print("Inventory is Full - Returning to deposit station.")
        local vLastMiningLocation = getCurrentCoordinates()
        local lastFacingDirection = table.shallow_copy(turtleTracking.direction) -- I think this is referencing the direction from turtle tracking..
        --print("Current direction: ", directionToString(lastFacingDirection))
        --print("Last mining X Y Z: ", vLastMiningLocation.x, vLastMiningLocation.y, vLastMiningLocation.z)

        print("Navigating to depositing station X Y Z: ", vHomeLocation.x, vHomeLocation.y, vHomeLocation.z)
        navigateTo(vHomeLocation)

        print("Looking for chest to deposit ore..")
        checkForChest()

        print("Found chest.")
        print("Depositing inventory..")
        for i=1, 16 do 
          if turtle.getItemCount(i) > 0 then
            turtle.select(i)
            turtle.drop()
          end
        end
        turtle.select(1) -- reset selection

        local turtleFuelLevelPercentage = ( turtle.getFuelLevel() / turtle.getFuelLimit() ) * 100

        print("Fuel level: "..turtleFuelLevelPercentage, "%")

        if turtleFuelLevelPercentage <= 50 then
          print("Refueling..")
          -- yeah yeah I know, a fuel depot right above the message cube..
          turtle.up()
          turtle.up()
          checkForChest()
          local hasSuckedCoal, reason = turtle.suck(16)
          while not hasSuckedCoal do
            -- Emit redstone to speaker to notify me of low fuel
            redstone.setOutput("right", true)
            sleep(0.10)
            redstone.setOutput("right", false)

            print("Press enter to continue after refueling fuel depot")
            read()
            hasSuckedCoal, reason = turtle.suck(16)
          end
          turtle.refuel(16)
          turtle.down()
          turtle.down()
        else
          print("No need to refuel.")
        end

        print("Navigating to mining location X Y Z: ", vLastMiningLocation.x, vLastMiningLocation.y, vLastMiningLocation.z)
        -- print("direction to resume: ", directionToString(lastFacingDirection))
        navigateTo(vLastMiningLocation)
        turtleTracking:turnTo(lastFacingDirection)
      end

      digAndMoveForward()
    end

    -- Avoid cutting into the edge on the last column
    if y < column then -- Don't remember why these are the way they are
      endOfRowMovement(y)
    end
  end
  if z < height then -- Don't remember why these are the way they are
    digDownMoveDownAndTurnAround(2)
  end
end

finishWork()
