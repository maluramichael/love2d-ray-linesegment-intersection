local vector = require "thirdparty.hump.vector"

lines = {
  {from = vector.new(50, 100), to = vector.new(750, 100)},
  {from = vector.new(350, 600), to = vector.new(400, 300)},
  {from = vector.new(400, 650), to = vector.new(600, 680)}
}

player = vector.new(400, 400)
enemies = {}
rays = {}

for y = 1, 4 do
  for x = 1, 4 do
    table.insert(enemies, vector.new(x * 150, y * 150))
  end
end

function createRay(from, to)
  local direction = (to - from):normalized()
  return {from = from, to = to, direction = direction}
end

-- https://stackoverflow.com/a/32146853 thanks ezolotko
function rayIntersection(ray, p1, p2)
  local v1 = ray.from - p1
  local v2 = p2 - p1
  local v3 = {x = -ray.direction.y, y = ray.direction.x}

  local d = v2 * v3

  ray.v1 = v1
  ray.v2 = v2
  ray.v3 = v3
  ray.d = d

  if math.abs(d) < 0.00001 then
    return nil
  end

  local t1 = v2:cross(v1) / d
  local t2 = (v1 * v3) / d

  ray.t1 = t1
  ray.t2 = t2

  if t1 >= 0 and (t2 >= 0 and t2 <= 1) then
    return t1
  end
  return nil
end

function love.load()
  love.graphics.setBackgroundColor(0.2, 0.2, 0.3)
end

function love.update(dt)
  player.x, player.y = love.mouse.getPosition()

  -- clear ray table
  for k, v in pairs(rays) do
    rays[k] = nil
  end

  -- cast rays
  for _, enemy in ipairs(enemies) do
    table.insert(rays, createRay(enemy, player))
  end

  -- check rays
  for _, ray in ipairs(rays) do
    for _, line in ipairs(lines) do
      -- hit will be the length of vector ray.from to to hit point
      local hit = rayIntersection(ray, line.from, line.to)
      -- local hit = raySegment(ray.from, ray.direction, line.from, line.to)
      if hit ~= nil then

        if ray.hit == nil or hit < ray.hit then
          -- create a new vector which sits exactly on the hitpoint
          local rayLength = (ray.to - ray.from):len()
          if hit < rayLength then
            ray.hitDestination = true
            ray.to = ((ray.to - ray.from):normalized() * hit) + ray.from
            ray.hit = hit
          end
        end
      end
    end
  end
end

function love.draw()
  -- draw rays
  for _, ray in ipairs(rays) do
    if ray.hit ~= nil and ray.hitDestination then
      love.graphics.setLineWidth(3)
      love.graphics.setColor(1, 0, 0, 1)
      love.graphics.line(ray.from.x, ray.from.y, ray.to.x, ray.to.y)
    else
      love.graphics.setColor(1, 1, 0, 1)
      love.graphics.setLineWidth(1)
      love.graphics.line(ray.from.x, ray.from.y, ray.to.x, ray.to.y)
    end
  end

  -- draw walls
  love.graphics.setLineWidth(3)
  love.graphics.setColor(1, 1, 1, 1)
  for _, line in ipairs(lines) do
    love.graphics.line(line.from.x, line.from.y, line.to.x, line.to.y)
  end

  -- draw player
  love.graphics.setColor(1, 0, 1, 1)
  love.graphics.circle("fill", player.x, player.y, 5)

  -- draw enemies
  love.graphics.setColor(1, 0, 0, 1)
  for _, enemy in ipairs(enemies) do
    love.graphics.circle("fill", enemy.x, enemy.y, 5)
  end
end

function love.keypressed(key, scancode, isrepeat)
  if key == "escape" then
    love.event.quit()
  end
end
