--- Load default values for all global variables
function love.load()
  --- Game constants
  paddleXOffset = 20
  paddleSteps = 10
  windowWidth, windowHeight = love.graphics.getDimensions()
  mode = "fill"
  scoreLeft = 0
  scoreRight = 0

  --- Game Objects
  -- 0 degrees heading is to the right, 90 degrees is straight down (because larger Y moves the ball downwards)
  ball = { x = windowWidth / 2, y = windowHeight / 2, radius = 10, heading = getRandomHdg(), speed = 10 }
  playerLeft = { x = paddleXOffset, y = windowHeight * 0.4, width = 10, height = 100 }
  playerRight = { x = windowWidth - 10 - paddleXOffset, y = windowHeight * 0.4, width = 10, height = 100 }

  --- Set paddle and ball draw color
  love.graphics.setColor(255, 255, 255)
end

--- Drow the paddles and ball
function love.draw()
  love.graphics.rectangle(mode, playerLeft.x, playerLeft.y, playerLeft.width, playerLeft.height)
  love.graphics.rectangle(mode, playerRight.x, playerRight.y, playerRight.width, playerRight.height)
  love.graphics.circle(mode, ball.x, ball.y, ball.radius)
  love.graphics.print(scoreLeft, windowWidth * 0.4, windowHeight * 0.1, 0, 2, 2)
  love.graphics.print(scoreRight, windowWidth * 0.6, windowHeight * 0.1, 0, 2, 2)
end

--- Update the positions of paddles and ball
function love.update(dt)
  updatePlayerLeft()
  updatePlayerRight()
  updateBall()
end

function updatePlayerLeft()
  --- Left player uses W/S keys
  if love.keyboard.isDown('w') then
    movePaddleUp(playerLeft)
  elseif love.keyboard.isDown('s') then
    movePaddleDown(playerLeft)
  end
end

function updatePlayerRight()
  --- Right player uses arrow keys
  if love.keyboard.isDown('up') then
    movePaddleUp(playerRight)
  elseif love.keyboard.isDown('down') then
    movePaddleDown(playerRight)
  end
end

function movePaddleUp(paddle)
  if paddle.y - paddleSteps < 0 then
    paddle.y = 0
  else
    paddle.y = paddle.y - paddleSteps
  end
end

function movePaddleDown(paddle)
  if paddle.y + paddle.height + paddleSteps > windowHeight then
    paddle.y = windowHeight - paddle.height
  else
    paddle.y = paddle.y + paddleSteps
  end
end

function updateBall()
  dX = math.ceil(ball.speed * math.cos(math.rad(ball.heading)))
  dY = math.ceil(ball.speed * math.sin(math.rad(ball.heading)))

  newX = ball.x + dX
  newY = ball.y + dY

  if ballHitsTopBoundary(dY) or ballHitsBottomBoundary(dY) then

    --- subtract the dY instead of adding and change the heading
    newY = ball.y - dY
    ball.heading = 360 - ball.heading

  elseif ballHitsPlayerLeft(dX, dY) or ballHitsPlayerRight(dX, dY) then

    --- subtract the dX instead of adding and change the heading
    newX = ball.x - dX
    ball.heading = math.fmod(540 - ball.heading, 360)

  elseif ballHitsLeftBoundary(dX) or ballHitsRightBoundary(dX) then

    if ballHitsLeftBoundary(dX) then
      scoreRight = scoreRight + 1
    else
      scoreLeft = scoreLeft + 1
    end

    newX = windowWidth / 2
    newY = windowHeight / 2
    ball.heading = getRandomHdg()

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

function ballHitsPlayerLeft(dX, dY)
  return pointInRectangle( ball.x + dX, ball.y + dY, playerLeft.x, playerLeft.y, playerLeft.width, playerLeft.height)
end

function ballHitsPlayerRight(dX, dY)
  return pointInRectangle(ball.x + dX, ball.y + dY, playerRight.x, playerRight.y, playerRight.width, playerRight.height)
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

--- Trying to get random headings but keep them on the interval of [0, 45], [135, 225], [315, 360]
function getRandomHdg()
  r = math.random()
  if r <= 0.25 then
    r = math.random() * 45
  elseif r <= 0.75 then
    r = math.random() * 90 + 135
  else
    r = math.random() * 45 + 315
  end
  return r
end
