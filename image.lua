function love.load()
  screenshot = love.graphics.newImage("screenshot.jpg")
end

function love.draw()
  love.graphics.draw(screenshot, 300, 200)
end
