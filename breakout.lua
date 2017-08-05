--- Load default values for all global variables
function love.load()
  --- Game constants
  paddleOffset = 20
  paddleSteps = 10
  windowWidth, windowHeight = love.graphics.getDimensions()
  fillMode = "fill"
  lineMode = "line"
  score = 0
  ballsRemaining = 3
  paddleDirection = 0
  gameOver = false

  --- Game Objects
  -- 0 degrees heading is to the right, 90 degrees is straight down (because larger Y moves the ball downwards)
  objects = {}
  ball = { x = windowWidth / 2, y = windowHeight / 2, radius = 10, heading = math.random(360), speed = 10 }
  paddle = { x = windowWidth * 0.5, y = windowHeight - paddleOffset - 10, width = 100, height = 10 }
  objects.ball = ball
  objects.paddle = paddle

  -- going to start with just one layer of bricks
  brickHeight = 25
  brickWidth = 50
  brickMargin = math.fmod(windowWidth, brickWidth) / 2
  numBricks = math.floor( (windowWidth - brickMargin * 2) / brickWidth)
  brickY = windowHeight * 0.1

  bricks = {}
  for i=1,numBricks do
    bricks[i] = true
  end

  objects.bricks = bricks
end

--- Drow the paddles and ball
function love.draw()
  drawPaddle()
  drawBall()
  drawBricks()
  drawInfo()
end

--- Update the positions of the paddle and ball
function love.update(dt)
  if gameOver then return end

  updatePaddle()
  updateBall()

  if allBricksDestroyed() then
    gameOver = true
    ball.speed = 0
  end
end

function drawInfo()
  setDrawColorGrey()
  love.graphics.print("B: " .. ballsRemaining, windowWidth * 0.9, windowHeight * 0.2)
  love.graphics.print("S: " .. score, windowWidth * 0.9, windowHeight * 0.2 + 30)

  if gameOver then
    setDrawColorWhite()
    love.graphics.print("Game Over!", windowWidth / 3, windowHeight / 3, 0, 5)
  end
end

function drawPaddle()
  setDrawColorGrey()
  love.graphics.rectangle(fillMode, paddle.x, paddle.y, paddle.width, paddle.height)
end

function drawBall()
  setDrawColorWhite()
  love.graphics.circle(fillMode, ball.x, ball.y, ball.radius)
end

function drawBricks()
  x = brickMargin
  y = brickY

  for i,exists in ipairs(bricks) do
    if exists then
      setDrawColorGrey()
      love.graphics.rectangle(lineMode, x, y, brickWidth, brickHeight)
      setDrawColorRed()
      love.graphics.rectangle(fillMode, x+1, y+1, brickWidth-2, brickHeight-2)
    end
    x = x + brickWidth
  end
end

function setDrawColorWhite()
  love.graphics.setColor(255, 255, 255)
end

function setDrawColorRed()
  love.graphics.setColor(255, 0, 0)
end

function setDrawColorGrey()
  love.graphics.setColor(127, 127, 127)
end

function updatePaddle()
  --- player uses arrow keys
  if love.keyboard.isDown('left') then
    movePaddleLeft()
    paddleDirection = -1
  elseif love.keyboard.isDown('right') then
    movePaddleRight()
    paddleDirection = 1
  else
    paddleDirection = 0
  end
end

function movePaddleLeft()
  if paddle.x - paddleSteps < 0 then
    paddle.x = 0
  else
    paddle.x = paddle.x - paddleSteps
  end
end

function movePaddleRight()
  if paddle.x + paddle.width + paddleSteps > windowWidth then
    paddle.x = windowWidth - paddle.width
  else
    paddle.x = paddle.x + paddleSteps
  end
end

function updateBall()
  dX = math.ceil(ball.speed * math.cos(math.rad(ball.heading)))
  dY = math.ceil(ball.speed * math.sin(math.rad(ball.heading)))

  newX = ball.x + dX
  newY = ball.y + dY

  if ballHitsTopBoundary(dY) or ballHitsPaddle(dX, dY) then
    -- subtract the dY instead of adding and change the heading
    -- and allow the user to change the heading if the paddle is moving during contact
    newY = ball.y - dY
    ball.heading = 360 - ball.heading
    
    if ballHitsPaddle(dX, dY) then
      -- Give the user ability to affect the ball heading within a certain bounds
      ball.heading = math.min(315, math.max(225, ball.heading + 15 * paddleDirection))
    end

  elseif ballHitsLeftBoundary(dX) or ballHitsRightBoundary(dX) then
    -- subtract the dX instead of adding and change the heading
    newX = ball.x - dX
    ball.heading = math.fmod(540 - ball.heading, 360)
  elseif ballHitsBottomBoundary(dY) then
    if ballsRemaining > 0 then
      ballsRemaining = ballsRemaining - 1
      newX = windowWidth / 2
      newY = windowHeight / 2
      ball.heading = math.random(360)
    else
      ball.speed = 0
      gameOver = true
    end
  elseif ballHitsBrick(dX, dY) then
      destroyBrick(brickIndexAt(newX, newY))
      score = score + 1
      newY = ball.y - dY
      ball.heading = 360 - ball.heading
  end

  ball.x = newX
  ball.y = newY
end

function ballHitsTopBoundary(dY)
  return ball.y + dY - ball.radius <= 0
end

function ballHitsBottomBoundary(dY)
  return ball.y + dY + ball.radius >= windowHeight
end

--- The ball/paddle collision detection is extremely rudimentary and not a true collision detection.
--- We simply check if the center of the ball is within the area of the paddle.
--- I took this shortcut for rapid development purposes

function ballHitsPaddle(dX, dY)
  return pointInRectangle(ball.x + dX, ball.y + dY, paddle.x, paddle.y, paddle.width, paddle.height)
end

function ballHitsBrick(dX, dY)
  newX = ball.x + dX
  newY = ball.y + dY

  if brickY < newY and newY < brickY + brickHeight then
    -- We are at the right height. Check if we are on an enabled brick
    brickIndex = brickIndexAt(newX, newY)
    if bricks[brickIndex] then return true else return false end
  else
    return false
  end
end

function ballHitsLeftBoundary(dX)
  return ball.x + dX - ball.radius <= 0
end

function ballHitsRightBoundary(dX)
  return ball.x + dX + ball.radius >= windowWidth
end

function pointInRectangle(px, py, rx, ry, rw, rh)
  return px >= rx and px <= rx + rw and py >= ry and py <= ry + rh
end

function brickIndexAt(x, y)
  return math.ceil( (x - brickMargin) / brickWidth)
end

function destroyBrick(index)
  bricks[index] = false
end

function allBricksDestroyed()
  for i,brick in ipairs(bricks) do
    if brick then
      return false
    end
  end
  return true
end
