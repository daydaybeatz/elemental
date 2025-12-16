	------------------------------------------------------------
	-- i_particle : create an emitter
	------------------------------------------------------------
	-- i_particle(ptype, amt_min, amt_max, size_min, size_max, 
	--            life_min, life_max, total_duration, 
	--            x, y, colors)
	
	--"blast", "smoke", "burn", "spark", "ring", "trail", "rain", "embers", "aura"
	
	--dont forget to call:
	--u_particle()
	--d_particle()
	------------------------------------------------------------


	function i_particle(ptype, amt_min, amt_max, size_min, size_max,
	                    life_min, life_max, total_duration,
	                    x, y, colors, space)
	
	  -- normalize space
	  if space == true then space = "screen" end
	  if space == nil or space == false then space = "world" end
	
	  local lm, lx = life_min, life_max
	  if ptype ~= "blood" then
	    lm = lm or 15
	    lx = lx or lm or 15
	  end
	
	  local e = {
	    kind      = ptype or "blast",
	    amt_min   = amt_min  or 5,
	    amt_max   = amt_max  or amt_min or 5,
	    size_min  = size_min or 1,
	    size_max  = size_max or size_min or 1,
	    life_min  = lm,
	    life_max  = lx,
	    duration  = total_duration or 1,
	    t         = 0,
	    x         = x or 0,
	    y         = y or 0,
	    colors    = colors,
	    spawned   = false,
	
	    space     = space,  -- "world" or "screen"
	  }
	
	  add(emitters, e)
	  return e
	end
	
	
	
	
	-- 3) PATCH ALL PARTICLE SPAWNERS TO COPY e.space INTO ps.space
	--    (only changed lines are the "space = e.space" additions)
	
	local function spawn_blood(e)
	    if e.spawned then return end
	    e.spawned = true
	
	    local amt = rand_int_range(e.amt_min, e.amt_max)
	
	    for i=1,amt do
	        local ang  = rnd(1) * two_pi
	        local spd  = 0.8 + rnd(1.5)
	        local size = lerp(e.size_min, e.size_max, rnd())
	
	        local life, life_max = nil, nil
	        if e.life_min and e.life_max then
	            life     = rand_int_range(e.life_min, e.life_max)
	            life_max = life
	        end
	
	        local ps = {
	            x = e.x, y = e.y,
	            dx = cos(ang) * spd,
	            dy = sin(ang) * spd,
	            life     = life,
	            life_max = life_max,
	            size     = size,
	            kind     = "blood",
	            colors   = e.colors,
	            friction = 0.85,
	
	            space    = e.space, -- NEW
	        }
	        add(particles, ps)
	    end
	end
	
	local function spawn_blast(e)
	    if e.spawned then return end
	    e.spawned = true
	
	    local amt = rand_int_range(e.amt_min, e.amt_max)
	    for i=1,amt do
	        local ang  = rnd(1) * two_pi
	        local spd  = 0.5 + rnd(1.5)
	        local life = rand_int_range(e.life_min, e.life_max)
	        local size = lerp(e.size_min, e.size_max, rnd())
	
	        local ps = {
	            x = e.x, y = e.y,
	            dx = cos(ang) * spd,
	            dy = sin(ang) * spd,
	            life     = life,
	            life_max = life,
	            size     = size,
	            kind     = "blast",
	            colors   = e.colors,
	
	            space    = e.space, -- NEW
	        }
	        add(particles, ps)
	    end
	end
	
	local function spawn_spark(e)
	    if e.spawned then return end
	    e.spawned = true
	
	    local amt = rand_int_range(e.amt_min, e.amt_max)
	    for i=1,amt do
	        local ang  = rnd(1) * two_pi
	        local spd  = 1.5 + rnd(2.0)
	        local life = rand_int_range(e.life_min, e.life_max)
	        local size = lerp(e.size_min, e.size_max, rnd())
	
	        local ps = {
	            x = e.x, y = e.y,
	            dx = cos(ang) * spd,
	            dy = sin(ang) * spd,
	            life     = life,
	            life_max = life,
	            size     = size,
	            kind     = "spark",
	            colors   = e.colors,
	            g        = 0.15,
	
	            space    = e.space, -- NEW
	        }
	        add(particles, ps)
	    end
	end
	
	local function spawn_ring(e)
	    if e.spawned then return end
	    e.spawned = true
	
	    local amt = rand_int_range(e.amt_min, e.amt_max)
	    if amt < 3 then amt = 3 end
	
	    for i=1,amt do
	        local t    = i / amt
	        local ang  = t * two_pi
	        local spd  = 0.8 + rnd(0.5)
	        local life = rand_int_range(e.life_min, e.life_max)
	        local size = lerp(e.size_min, e.size_max, rnd())
	
	        local ps = {
	            x = e.x, y = e.y,
	            dx = cos(ang) * spd,
	            dy = sin(ang) * spd,
	            life     = life,
	            life_max = life,
	            size     = size,
	            kind     = "ring",
	            colors   = e.colors,
	
	            space    = e.space, -- NEW
	        }
	        add(particles, ps)
	    end
	end
	
	local function spawn_smoke(e)
	    local amt = rand_int_range(e.amt_min, e.amt_max)
	    for i=1,amt do
	        local side = (rnd(0.5) - 0.25)
	        local spd  = 0.05 + rnd(0.2)
	        local life = rand_int_range(e.life_min, e.life_max)
	        local s0   = lerp(e.size_min, e.size_max, rnd())
	
	        local ps = {
	            x = e.x, y = e.y,
	            dx = side,
	            dy = -0.3 + spd,
	            life      = life,
	            life_max  = life,
	            size      = s0,
	            size0     = s0,
	            size1     = e.size_max or s0 + 1,
	            kind      = "smoke",
	            colors    = e.colors,
	
	            space     = e.space, -- NEW
	        }
	        add(particles, ps)
	    end
	end
	
	local function spawn_burn(e)
	    local osc = (sin(e.t * 0.1) + 1) * 0.5
	    local base_amt = lerp(e.amt_min, e.amt_max, osc)
	    local amt = max(1, flr(base_amt + 0.5))
	
	    for i=1,amt do
	        local ang  = rnd(1) * two_pi
	        local spd  = 0.3 + rnd(0.5)
	        local life = rand_int_range(e.life_min, e.life_max)
	        local size = lerp(e.size_min, e.size_max, rnd())
	
	        local ps = {
	            x = e.x, y = e.y,
	            dx = cos(ang) * spd * 0.3,
	            dy = -0.2 + sin(ang) * 0.2,
	            life      = life,
	            life_max  = life,
	            size      = size,
	            kind      = "burn",
	            colors    = e.colors,
	
	            space     = e.space, -- NEW
	        }
	        add(particles, ps)
	    end
	end
	
	local function spawn_trail(e)
	    local amt = rand_int_range(e.amt_min, e.amt_max)
	    for i=1,amt do
	        local ang  = rnd(1) * two_pi
	        local spd  = rnd(0.3)
	        local life = rand_int_range(e.life_min, e.life_max)
	        local size = lerp(e.size_min, e.size_max, rnd())
	
	        local ps = {
	            x = e.x, y = e.y,
	            dx = cos(ang) * spd,
	            dy = sin(ang) * spd,
	            life      = life,
	            life_max  = life,
	            size      = size,
	            kind      = "trail",
	            colors    = e.colors,
	
	            space     = e.space, -- NEW
	        }
	        add(particles, ps)
	    end
	end
	
	local function spawn_rain(e)
	    local amt = rand_int_range(e.amt_min, e.amt_max)
	    for i=1,amt do
	        local px   = e.x + rnd(16) - 8
	        local life = rand_int_range(e.life_min, e.life_max)
	        local size = lerp(e.size_min, e.size_max, rnd())
	
	        local ps = {
	            x = px, y = e.y,
	            dx = 0,
	            dy = 1.0 + rnd(0.5),
	            life      = life,
	            life_max  = life,
	            size      = size,
	            kind      = "rain",
	            colors    = e.colors,
	
	            space     = e.space, -- NEW
	        }
	        add(particles, ps)
	    end
	end
	
	local function spawn_embers(e)
	    local amt = rand_int_range(e.amt_min, e.amt_max)
	    for i=1,amt do
	        local px   = e.x + rnd(4) - 2
	        local life = rand_int_range(e.life_min, e.life_max)
	        local size = lerp(e.size_min, e.size_max, rnd())
	
	        local ps = {
	            x = px, y = e.y,
	            dx = (rnd(0.2) - 0.1),
	            dy = -(0.5 + rnd(0.3)),
	            life      = life,
	            life_max  = life,
	            size      = size,
	            kind      = "embers",
	            colors    = e.colors,
	
	            space     = e.space, -- NEW
	        }
	        add(particles, ps)
	    end
	end
	
	local function spawn_aura(e)
	    if e.spawned then return end
	    e.spawned = true
	
	    local amt = rand_int_range(e.amt_min, e.amt_max)
	    if amt < 3 then amt = 3 end
	
	    for i=1,amt do
	        local t    = i / amt
	        local ang  = t * two_pi
	        local life = rand_int_range(e.life_min, e.life_max)
	
	        local ps = {
	            emitter    = e,
	            angle      = ang,
	            radius_min = e.size_min,
	            radius_max = e.size_max,
	            omega      = 0.03 + rnd(0.03),
	            x          = e.x,
	            y          = e.y,
	            life       = life,
	            life_max   = life,
	            size       = 1,
	            kind       = "aura",
	            colors     = e.colors,
	
	            space      = e.space, -- NEW
	        }
	        add(particles, ps)
	    end
	end
	
	
	local function spawn_for_emitter(e)
	    if e.kind == "blast" then
	        spawn_blast(e)
	    elseif e.kind == "spark" then
	        spawn_spark(e)
	    elseif e.kind == "ring" then
	        spawn_ring(e)
	    elseif e.kind == "smoke" then
	        spawn_smoke(e)
	    elseif e.kind == "burn" then
	        spawn_burn(e)
	    elseif e.kind == "trail" then
	        spawn_trail(e)
	    elseif e.kind == "rain" then
	        spawn_rain(e)
	    elseif e.kind == "embers" then
	        spawn_embers(e)
	    elseif e.kind == "aura" then
	        spawn_aura(e)
	    elseif e.kind == "blood" then
	        spawn_blood(e)
	    else
	        -- default: just treat unknown as blast
	        spawn_blast(e)
	    end
	end
	
	function u_particle()
	    -- update emitters and spawn new particles
	    for e in all(emitters) do
	        e.t += 1
	
	        -- spawn while within duration; for one-shots, spawn_xxx
	        -- will self-guard using e.spawned
	        if e.duration <= 0 or e.t <= e.duration then
	            spawn_for_emitter(e)
	        end
	    end
	
	    -- update particles
	    for ps in all(particles) do
	        local kill = false
	
	        -- finite lifetime only if life is non-nil
	        if ps.life ~= nil then
	            ps.life -= 1
	            if ps.life <= 0 then
	                kill = true
	            end
	        end
	
	        if not kill then
	            local kind = ps.kind
	
	            if kind == "aura" then
	                -- orbit around emitter center
	                local e = ps.emitter
	                local cx = e and e.x or ps.x
	                local cy = e and e.y or ps.y
	                ps.angle += ps.omega or 0.03
	
	                local t = 0.5
	                if ps.life and ps.life_max and ps.life_max > 0 then
	                    t = 1 - (ps.life / ps.life_max)
	                end
	                t = 0.5 + 0.5 * sin(t * 0.5 * two_pi)
	
	                local r = lerp(ps.radius_min or 2, ps.radius_max or 8, t)
	                ps.x = cx + cos(ps.angle) * r
	                ps.y = cy + sin(ps.angle) * r
	
	            else
	                -- generic movement
	                ps.dx = ps.dx or 0
	                ps.dy = ps.dy or 0
	
	                -- style-specific forces
	                if kind == "smoke" then
	                    ps.dy -= 0.005
	                elseif kind == "spark" then
	                    ps.dy += ps.g or 0
	                elseif kind == "embers" then
	                    ps.dy -= 0.01 -- tiny extra lift
	                elseif kind == "blood" then
	                    -- slide ??? friction until nearly stopped
	                    local fr = ps.friction or 0.85
	                    ps.dx *= fr
	                    ps.dy *= fr
	                end
	
	                ps.x += ps.dx
	                ps.y += ps.dy
	            end
	
	            -- size animation (guard against nil life)
	            if kind == "smoke" and ps.life and ps.life_max and ps.life_max > 0 then
	                local t = 1 - (ps.life / ps.life_max)
	                local s0 = ps.size0 or ps.size
	                local s1 = ps.size1 or s0 + 1
	                ps.size = lerp(s0, s1, t)
	
	            elseif kind == "trail" and ps.life and ps.life_max and ps.life_max > 0 then
	                local t = 1 - (ps.life / ps.life_max)
	                ps.size = lerp(ps.size, 0, t * 0.2)
	            end
	        end
	
	        if kill then
	            del(particles, ps)
	        end
	    end
	end
	
	
function d_particle()
  local cx = cam.x or 0
  local cy = cam.y or 0

  for ps in all(particles) do
    local kind = ps.kind
    local r    = ps.size or 1

    local x = ps.x
    local y = ps.y

    -- per-particle space
    if ps.space == "world" then
      x -= cx
      y -= cy
    end

    local c = ps.col or 7
    if ps.colors then
      local t = 0
      if ps.life and ps.life_max and ps.life_max > 0 then
        t = 1 - (ps.life / ps.life_max)
      end
      if kind == "burn" then
        t = (sin(t * two_pi) + 1) * 0.5
      end
      c = sample_color(ps.colors, t)
    end

    if kind == "rain" then
      local h = 2 + r*2
      line(x, y-h, x, y, c)
    else
      circfill(x, y, r, c)
    end
  end
end
