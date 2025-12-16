include "utility.lua"


-- game code
function _init()
fetch("1.pal"):poke(0x5000)
mouse_x, mouse_y = mouse()
--vid(0) --hide mouse
init_ui()

--init stats
health=80
max_health=100
money=1025



--title screen
add(ap,"title")

---

---title gun deco
i_element({page="title",
type="container",
--label="locations main:",
pos={x=0,y=0},
size={w=111,h=111},
colors={33},
--sprites={6},
--rrect=9,
id="bg_1",
hide=true,

--visible=false,

draw=function()
spr_container(22, 0,0, 479, 269)


local max_x = flr(479/32)
local max_y = flr(269/32)

-- deterministic "random" from grid coords
local function coord_rand(i, ii, min, max)
    -- hash (i, ii) into a 0..1 float
    local n = sin(i*12.9898 + ii*78.233) * 43758.5453
    n = n - flr(n)
    return min + (max - min) * n
end

for i=0,max_x do
    for ii=0,max_y do
        if i == 0 or i == max_x or ii == 0 or ii == max_y then
            -- cycles 1,2,3,4,1,2,3,4...
            local spr_id = ((i + ii) % 4) + 1

            -- each edge tile gets its own speed in [0.05, 0.2]
            local speed = coord_rand(i, ii, 0.05, 0.2)

            -- rotation angle
            local angle = t() * speed

            rotate_sprite(spr_id, 10 + i*32.5, 10 + ii*31, 1, 1, angle)
        end
    end
end



end

})


--template elements:

--default remove button
i_element({
	id="remove_button",
	page="none",
	type="r_button",
	label="remove",
	confirm=true, 
	bullnose=1
})

-- default message box
	i_element({
	id="message",
	size={w=120,h=20},
	label="default text..........",
	space="screen",
--   hide=true,
	visible=false,
   page="none",
	type="container",
	colors={24},
   pos={x=140,y=230},
	slide = {140,330,140,230,.009},
	wipe={"left",.01},

	h_func=function(self)
--	if mouse_clicked then
--if other.id=="mouse" then
if mouse_clicked then
	click_msg="default destroy"
	ct=ctd
	toggle_element(self.id)
--	end
	end
	
	
	end,

draw=function(self,x,y)
rect(x,y,x+self.size.w,y+self.size.h,8)
if self.wipe.mode=="opening" then
shake(.5,20)
 i_particle("embers", 1, 2, 1, 2, 
            2, 3, 5, 
            x+self.wipe.t*self.size.w+2, y+rnd(self.size.h), {33,8,10})
 i_particle("embers", 1, 2, 1, 2, 
            2, 3, 5, 
            x+self.wipe.t*self.size.w+2, y+rnd(self.size.h), {33,8,10})
elseif self.wipe.mode=="closing" then
shake(.5,20)
 i_particle("embers", 1, 2, 1, 2, 
            2, 3, 5, 
            x+self.size.w-self.wipe.t*self.size.w-2, y+rnd(self.size.h), {33,8,10})
 i_particle("embers", 1, 2, 1, 2, 
            2, 3, 5, 
            x+self.size.w-self.wipe.t*self.size.w-2, y+rnd(self.size.h), {33,8,10})
end
end
})

---
--simple message
clone_element("message", {
page="main",
id="dialogue",
label="it's a text box...",
i_func=function()
--toggle_element("dialogue")
end,
func=function()

end,
	draw=function()
	spr(7,165,70)
	
	end,
})



---title
	i_element({
	type="spr_container",
	id="logo",
	sprites={7},
	size={w=125,h=125},
	pos={x=170,y=40},
	animation={"circle",2,.01},
--	label="default text..........",
--   hide=true,
--	visible=false,
   page="title",
--	type="container",
--	colors={24},
--   pos={x=10,y=10},
	slide = {200,300,200,200,.02}
--	wipe={"left",.01},
	

	})


--- start game button
i_element({page="title",type="container",
--pos={x=188,y=200},
size={w=63,h=12},
colors={47,35},
id="start_button",
animation={"circle", -2, .01},

arrange={"logo",32,128},
label="x  to  start",
	a_update=function(self)
--	shake_element("start_button",1,1)
	click_msg="default update"
	ct=ctd
	if btnp(4) then
	if page_is_active("title") then
	sfx(4)
	toggle_string(ap,"title")
	toggle_element("title")
	add(ap,"main")
	end
	end
	end
})


--init game
i_element({page="main",type="container",
behind_all=true,
hide=true,
i_func=function()
add(ap,"bullets")
add(ap,"players")
map_coords={0,0,0,0}
end
})

-----
--pickups
---
i_element({
type="container",
hide=true,
page="main",
world=true,
id="pistol_ammo",
label=".357 rounds",
offset={x=0,y=-12},
i_func=function()
toggle_element("pistol_ammo")
end,
  draw=function(self,x,y) -- x,y are SCREEN coords
    spr(25,x,y)
  end,
})


-- define bullet behaviors / visuals
BULLET_TYPES = {
    pistol = {
        speed   = 5.0,
        size    = 1,
        life    = 0.7,
        sprite  = 64,
        damage  = 1,
        color   = 7,
    },
    shotgun = {
        speed   = 3.5,
        size    = 2,
        life    = 0.4,
        sprite  = 65,
        damage  = 1,
        color   = 10,
    },
    heavy = {
        speed   = 3.0,
        size    = 3,
        life    = 1.0,
        sprite  = 66,
        damage  = 2,
        color   = 8,
    },
}

GUN_TYPES = {
    pistol = {
        bullet_type = "pistol",
        shoot_delay = 0.2,
        reload_time = 0.9,
        clip_size   = 6,
		  sprites={1,9},
particle = function(owner, dx, dy, mx, my)
--  i_particle("spark",
--    4, 6, 1, 1,
--    9, 11, 24,
--    mx, my,
--    {7,10,9},true
--  )
end


    },
    shotgun = {
        bullet_type = "shotgun",
        shoot_delay = 0.6,
        reload_time = 1.3,
        clip_size   = 2,
    },
    rifle = {
        bullet_type = "heavy",
        shoot_delay = 0.4,
        reload_time = 1.5,
        clip_size   = 4,
    },
}


---
PLAYER_ANIM = {
    idle = {40,41,42,43},
    walk = {44,45,46,47,48,49},
}
---


function player_get_frame(self)
    local frames, speed
    if self.state == "idle" then
        frames = PLAYER_ANIM.idle
        speed  = 3
    else
        frames = PLAYER_ANIM.walk
        speed  = (self.state == "dash") and 12 or 8
    end
    return animate(frames, speed)
end

i_element({
    type="container",
    page="players",
    size={w=16,h=16},
    hide=true,
	 world=true,
    id="player1",
	 pos={x=0,y=0},
	h_func=function()
	click_msg="player"
	ct=ctd
	
	end,

    data={
        gun       = "pistol",
        ammo      = 1000,
        clip      = 6,
        last_shot = 0,
        reloading = false,
        reload_t  = 0,
    },

    i_func=function(self)
--        add(ap,"players")
        self.vx = self.vx or 0
        self.vy = self.vy or 0

        self.state = self.state or "idle"
        self.dir   = self.dir   or "right"

        self.dashing   = self.dashing   or false
        self.dash_t    = self.dash_t    or 0
        self.dash_dur  = self.dash_dur  or 0.20

        -- gun / aim
        self.a   = self.a   or 0   -- angle in TURNS (0..1)
        self.gf  = self.gf  or 1   -- gun sprite index (1 = right, 9 = left)
        self.gxo = self.gxo or 14  -- gun x-offset from player

        self.aim_x = self.aim_x or 0
        self.aim_y = self.aim_y or 0
    end,

    update=function(self,x,y)
        local accel    = 0.2
        local friction = 0.85
        local max_spd  = 2.5

        -- ===== LEFT STICK: MOVEMENT (still using digital) =====
        local dx, dy = 0, 0
        if btn(0) then dx -= 1 end
        if btn(1) then dx += 1 end
        if btn(2) then dy -= 1 end
        if btn(3) then dy += 1 end

        if dx < 0 then
            self.dir = "left"
        elseif dx > 0 then
            self.dir = "right"
        end

        local ax = dx * accel
        local ay = dy * accel

        -- ===== RIGHT STICK: FULL 360 ANALOG AIM (index = 8) =====
        -- same math as your drawStick function
        local rsx = (btn(9) or 0)/255 - (btn(8) or 0)/255   -- right - left
        local rsy = (btn(11) or 0)/255 - (btn(10) or 0)/255 -- down - up

        -- deadzone
        local mag = sqrt(rsx*rsx + rsy*rsy)
        if mag < 0.15 then
            rsx, rsy = 0, 0
        end

        self.aim_x = rsx
        self.aim_y = rsy

        if rsx ~= 0 or rsy ~= 0 then
            local base_angle = atan2(rsy, rsx)  -- turns (0..1)

            if rsx < 0 then
                -- left hemisphere (this side looked correct before)
                self.gf  = 58      -- LEFT gun sprite
                self.gxo = 8      -- left-side offset
                self.a   = base_angle - 0.25

            elseif rsx > 0 then
                -- right hemisphere, mirrored
                self.gf  = 50      -- RIGHT gun sprite
                self.gxo = 13
                self.a   = base_angle + 0.25

            else
                -- pure vertical, keep current sprite but update angle
                if self.gf == 58 then
                    self.a = base_angle - 0.25
                else
                    self.a = base_angle + 0.25
                end
            end
        end

        -- ===== DASH (button 4) =====
        if btnp(14) and not self.dashing then
            if dx ~= 0 or dy ~= 0 then
                self.dashing = true
                self.dash_t  = time()

                local ds  = 7
                local len = sqrt(dx*dx + dy*dy)
                local ndx = dx / len
                local ndy = dy / len

                self.vx = ndx * ds
                self.vy = ndy * ds
            end
        end

        if self.dashing and time() - self.dash_t > self.dash_dur then
            self.dashing = false
        end

        if not self.dashing then
            self.vx += ax
            self.vy += ay
        end

        local spd = sqrt(self.vx*self.vx + self.vy*self.vy)
        if spd > max_spd and not self.dashing then
            self.vx = self.vx / spd * max_spd
            self.vy = self.vy / spd * max_spd
        end

        self.vx *= friction
        self.vy *= friction

        self.pos.x += self.vx
        self.pos.y += self.vy

        if self.dashing then
            self.state = "dash"
            i_particle("aura", 1, 1, 1, 2,
                       1, 7, 10,
                       self.pos.x+8, self.pos.y+16, {54,22,47})
        else
            if abs(self.vx) > 0.05 or abs(self.vy) > 0.05 then
                self.state = "walk"
            else
                self.state = "idle"
            end
        end

        -- ===== SHOOTING: use the SAME analog aim vector =====
        if btnp(15) then
            shoot(self, self.aim_x, self.aim_y)
--            click_msg = "fire!"
--            ct        = ctd
        end
    end,

draw=function(self, x, y)
  -- x,y are SCREEN coords already (world + camera applied by your element system)

  -- ===== HUD (screen space; keep as-is) =====
  bar(
    health, max_health,
    2, 24,
    {24,7,0,7},
    false,
    50, 13,
    {14,14,14},
    {15,15,15}
  )

  print(health, 50, 27, 54)

  print(self.data.clip.."/"..self.data.ammo, 5, 3, 7)
  print(self.data.clip, 5, 3, 7)

  spr(GUN_TYPES[self.data.gun].sprites[1], 35, -1)

  if self.data.clip==0 then
    f_print("RELOAD!", 9, 13, 7, 3, {8,7})
  end

  for i=1,self.data.clip do
    spr(17, -5 + i*8, 13)
  end

  -- ===== PLAYER BODY + GUN (WORLD -> SCREEN via x,y) =====
  local s      = player_get_frame(self)
  local flip_x = (self.dir == "left")

  -- body (USE x,y, not self.pos)
  spr(s, x, y, flip_x, false)

  -- gun (USE x,y, not self.pos)
  if self.aim_x ~= 0 or self.aim_y ~= 0 then
    rotate_sprite(
      self.gf,
      x + (self.gxo or 0),
      y + 10,
      1, 1,
      self.a
    )
  end
end


})



-----
--stats:
---
i_element({page="main",
type="spr_container",
label="stats:",
offset={x=5,y=2},
--pos={x=3,y=250},
sprites={6},
size={w=40,h=12},
arrange={"stats_bg",24,-12},
colors={1,7},
label_col=47,
--slide = {3,150,3,270,.07},
--visible=true,
--toggle_default=false,
i_func=function(self)
--toggle_element("stats_button")
--ui_force_closed("stats_button")
--self.arrange={"stats_bg",24,-12}
end,
--move=true,
--wipe={"up",1},
--rrect=9,
id="stats_button",
--mode = "closed",
--slide={0,0,63,139,1},
draw=function(self,x,y)

--local tot = total_variable("locations","upkeep")
--print_data(self,"total upkeep: "..tot, x, y, 7)
--print("hello",x+3,y+10)
end,

a_update=function()
if btnp(12) then
toggle_element("stats_bg",1,"main")
end
end

})




-- sliding stats panel
i_element({
    page  = "main",
    type  = "spr_container",
    id    = "stats_bg",
sprites={6},
    pos   = {x=3,y=150},          -- logical final position
    size  = {w=100,h=100},
    colors= {1,7},
visible=false,

--move=true,
--    rrect = 9,
--	 arrange = {"stats_move",0,12},
--    slide = {from_x, from_y, to_x, to_y, speed}
    -- starts off-screen at y=200, slides up to y=150
    slide = {3,270,3,150,.07},
-- wipe={dir,speed}
--per line wipe-in animation
--wipe={"up",.08},
update=function()

end,
    draw  = function(self,x,y)

--		  print("stats:",x+5,y+4,30)
--        local tot = total_variable("locations","upkeep")
--		  print("total upkeep: "..tot,x+5,y+90,7)
		print(" money: $"..money,x+15,y+10,47)
		spr(5,x+4,y+6)
		
--		bar(health, max_health, x+6, y+24,{24,7,0,7}, false, 87, 12,{14,14,14},{15,15,15})
--		spr_container(14,x+2,y+23,5,15)
--		print("health: "..health,x+8,y+27,38)
		
		--draw bar for health/etc.
		

    end,

    -- clicking the panel itself will toggle it (and its button) on/off
    h_func  = function(self)
--health-=1
--shake_element("stats_bg", .5, 2)
        -- element-level toggles
--        toggle_element("stats_main",   1)
--        toggle_element("stats_button", 1, "stats_main")
--toggle_element("stats_bg", 1, "main")
    end,
    c_func = function(self, other, other_id)
        -- other is the collider element
        -- other_id is other.id (string)

--        if other.id == "mouse" then
--            click_msg = "stats touched by mouse"
--			   ct = ctd
--        elseif other.tag == "tag" then
--
--        end

        
    end
})

init_slide_closed("stats_bg")

-- TEMPLATE: no fixed id, we auto-id on i_func using #crates+1
-- (and we MUST register into ui_ids AFTER setting the id)

crates = crates or {}

i_element({
  type="container",
template=true,
  page="none",
id = "crate",
tag="crate",
hide=true,
  -- IMPORTANT: don't set id here (or you'll collide / register wrong)
  world=true,
  offset={x=0,y=-10},

  pos={x=200,y=120},
  size={w=16,h=16},

  draw=function(self,x,y)
    spr(19, x, y)
  end,

c_func=function(self, other, wx, wy, sx, sy)
  if other.tag=="bullet" then
    sfx2(6)
    clone_element("pistol_ammo",{pos={x=wx,y=wy}}) -- world spawn

    if self.id then toggle_element(self.id) end
    click_msg=tostr(self.id)
    ct=ctd
  end
end
,
  i_func=function(self)
	give_id(self,crates,"crate_")
	toggle_element(self.id)
  end,
h_func=function(self, other, wx, wy, sx, sy)
--  if other.tag=="bullet" then
--    sfx2(6)
--    clone_element("pistol_ammo",{pos={x=wx,y=wy}}) -- world spawn

--    if self.id then toggle_element(self.id) end
    click_msg="crate"..self.pos.x.." "..self.pos.y
    ct=ctd
--  end
end

})

for i=1,10 do
clone_element("crate", {page="main", pos={x=rnd(512),y=rnd(512)}})
end

--end
end


function _update()
update_ui()
end


function _draw()
cls(0)

if map_coords then
camera(cam.x, cam.y)   -- world transform ON
map(map_coords)   
camera()
end

draw_ui()
--draw_grid(15,15,{8,12,38,1})
end


---

-- bullet factory: mark bullets world=true AND draw using x,y passed in
function i_bullet(owner, dir_x, dir_y, kind)
  if not owner then return end

  local pdata = owner.data or {}
  local gun   = GUN_TYPES[pdata.gun or "pistol"] or GUN_TYPES["pistol"]
  local bkey  = kind or gun.bullet_type or "pistol"
  local bt    = BULLET_TYPES[bkey] or BULLET_TYPES["pistol"]

  local dx, dy = dir_x or 0, dir_y or 0
  local len = sqrt(dx*dx + dy*dy)
  if len == 0 then
    dx = (owner.dir == "left") and -1 or 1
    dy = 0
    len = 1
  end
  dx /= len
  dy /= len

  local start_x = owner.pos.x + 8
  local start_y = owner.pos.y + 8

  i_element({
    type="container",
    page="bullets",
    world=true,                 -- << IMPORTANT
    tag="bullet",               -- << IMPORTANT (don???t rely on id="bullet")
    size={w=bt.size*2,h=bt.size*2},
    hide=false,

    data={ type_key=bkey, damage=bt.damage },

    i_func=function(self)
      self.pos   = self.pos or {}
      self.pos.x = start_x
      self.pos.y = start_y
      self.vx    = bt.speed * dx
      self.vy    = bt.speed * dy
      self.life  = bt.life
      self.spawn_t = time()
      self.radius  = bt.size
      self.dead    = false
    end,

    update=function(self)
      self.pos.x += self.vx
      self.pos.y += self.vy

      if time() - self.spawn_t > self.life then self.dead = true end
      if self.pos.x < -8 or self.pos.x > 512 or self.pos.y < -8 or self.pos.y > 512 then
        self.dead = true
      end

      if self.dead then
        self.visible=false
        self.kill=true
      end
    end,

    draw=function(self, x, y)
      -- x,y are SCREEN coords when world=true (camera already applied by UI system)
      circfill(x, y, self.radius, BULLET_TYPES[self.data.type_key].color)
    end
  })
end



function shoot(self, aim_dx, aim_dy)
  local pdata = self.data or {}
  local gun   = GUN_TYPES[pdata.gun or "pistol"] or GUN_TYPES["pistol"]
  local now   = time()

  pdata.clip      = pdata.clip      or 0
  pdata.ammo      = pdata.ammo      or 0
  pdata.last_shot = pdata.last_shot or 0
  pdata.reloading = pdata.reloading or false
  pdata.reload_t  = pdata.reload_t  or 0

  -- finish reload
  if pdata.reloading then
    if now - pdata.reload_t >= gun.reload_time then
      local need  = gun.clip_size - pdata.clip
      local avail = pdata.ammo
      if need  < 0 then need  = 0 end
      if avail < 0 then avail = 0 end

      local load = need
      if load > avail then load = avail end

      pdata.clip = pdata.clip + load
      pdata.ammo = pdata.ammo - load
      pdata.reloading = false
    else
      return
    end
  end

  -- start reload if empty
  if pdata.clip <= 0 then
    if pdata.ammo > 0 and not pdata.reloading then
      pdata.reloading = true
      pdata.reload_t  = now
      sfx(5)
      pdata.clip = gun.clip_size
      pdata.ammo -= pdata.clip
    end
    return
  end

  -- respect shoot delay
  if now - pdata.last_shot < gun.shoot_delay then return end

  -- require aim
  local dx, dy = aim_dx or 0, aim_dy or 0
  if dx == 0 and dy == 0 then return end

  pdata.last_shot = now
  pdata.clip      = pdata.clip - 1

  -- WORLD muzzle position (match your gun draw y+10)
  local mx, my = get_world_pos(self, (self.gxo or 0), 10)

  -- small forward nudge toward aim (optional)
  mx += dx * 4
  my += dy * 4

  i_bullet(self, dx, dy, gun.bullet_type)

  if gun.particle then
    gun.particle(self, dx, dy, mx, my) -- << WORLD coords passed in
  end

  sfx(4)
  shake(2,4)
end
