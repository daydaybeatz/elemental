	
	
	---
	-- helper: get element by id from a ui[page] list
	function get_el_by_id(id, page)
	    page = page or "players"   -- default page
	
	    local list = ui[page]
	    if not list then return nil end
	
	    for i=1,#list do
	        local e = list[i]
	        if e and e.id == id then
	            return e
	        end
	    end
	
	    return nil
	end
	
	
	
	function cam_find_target()
	  if ui_ids and cam.target_id then
	    local t = ui_ids[cam.target_id]
	    if t and t.visible ~= false then return t end
	  end
	  return nil
	end
	
	---
	
	function update_mouse_edge()
	    local mx, my, mb = mouse()
	
	    -- left button
	    mouse_clicked  = (mb == 1 and mouse_mb_prev ~= 1)
	    mouse_released = (mb ~= 1 and mouse_mb_prev == 1)
	
	    -- right button (optional)
	    mouse_r_clicked  = (mb == 2 and mouse_mb_prev ~= 2)
	    mouse_r_released = (mb ~= 2 and mouse_mb_prev == 2)
	
	    mouse_mb_prev = mb
	end
	
	function mouse_in_elem_space(e, mx, my)
	  if e and e.world then
	    return mx + (_cam_x or 0), my + (_cam_y or 0)
	  end
	  return mx, my
	end
	
function screen_to_world(x,y)
  return x + (cam.x or 0), y + (cam.y or 0)
end

function world_to_screen(x,y)
  return x - (cam.x or 0), y - (cam.y or 0)
end
	
	--========================================================
	-- helpers: anchor + center
	--========================================================
	function elem_is_center_anchored(e)
	  -- treat these as "pos is center"
	  return (e.anchor == "center")
	      or (e.type == "c_button")
	      or (e.type == "spr_c_button")
	      or (e.r ~= nil)
	end
	
	function elem_center_xy(e)
	  local x = (e.pos and e.pos.x) or 0
	  local y = (e.pos and e.pos.y) or 0
	
	  if elem_is_center_anchored(e) then
	    return x, y
	  end
	
	  local w = (e.size and e.size.w) or 0
	  local h = (e.size and e.size.h) or 0
	  return x + w*0.5, y + h*0.5
	end


----


	
	--========================================================
	-- world clamp by element id string
	-- keeps the *visual* body inside world bounds
	--========================================================
	-- clamp element (by id string) to world bounds
	-- pad_x / pad_y apply ONLY to the right + bottom edges
	function u_world_clamp(id, mw, mh, tw, th, pad_x, pad_y)
	  local e = get_player_by_id(id)
	  if not e or e.visible == false then return end
	
	  pad_x = pad_x or 0
	  pad_y = pad_y or 0
	
	  local world_w = mw * tw
	  local world_h = mh * th
	
	  local w = (e.size and e.size.w) or 16
	  local h = (e.size and e.size.h) or 16
	
	  e.pos.x = clamp(e.pos.x, 0, (world_w - w) - pad_x)
	  e.pos.y = clamp(e.pos.y, 0, (world_h - h) - pad_y)
	end
	
	
	--========================================================
	-- camera tuning knobs (set once somewhere)
	--========================================================
	-- tunables (mess with these)
	cam = cam or {}
	cam.x, cam.y = cam.x or 0, cam.y or 0
	cam.w, cam.h = cam.w or 480, cam.h or 270
	cam.target_id = cam.target_id or "player1"
	
	cam.center_x = cam.center_x or 0.5   -- 0.5 = dead center, 0.45 etc shifts framing
	cam.center_y = cam.center_y or .04
	cam.ofs_x    = cam.ofs_x or 0         -- pixel offsets
	cam.ofs_y    = cam.ofs_y or 0
	cam.lerp     = cam.lerp or .15        -- 1 = tight, 0.15 = smooth
	
	--========================================================
	-- camera edge lock + optional smoothing + deadzone
	--========================================================
	-- edge-locked camera follow (world is mw*tw by mh*th)
	function u_camera_edge_lock(mw, mh, tw, th)
	  local p = get_player_by_id(cam.target_id)
	  if not p or p.visible == false then return end
	
	  -- IMPORTANT: p.pos must be WORLD coords (top-left)
	  local px = (p.pos and p.pos.x) or 0
	  local py = (p.pos and p.pos.y) or 0
	  local pw = (p.size and p.size.w) or 16
	  local ph = (p.size and p.size.h) or 16
	
	  local cx = px + pw*0.5 + cam.ofs_x
	  local cy = py + ph*0.5 + cam.ofs_y
	
	  local want_x = cx - cam.w * cam.center_x
	  local want_y = cy - cam.h * cam.center_y
	
	  local world_w = mw * tw
	  local world_h = mh * th
	  local max_x = max(0, world_w - cam.w)
	  local max_y = max(0, world_h - cam.h)
	
	  want_x = clamp(want_x, 0, max_x)
	  want_y = clamp(want_y, 0, max_y)
	
	  cam.x += (want_x - cam.x) * cam.lerp
	  cam.y += (want_y - cam.y) * cam.lerp
	
	  -- optional anti-jitter (recommended if you see wobble)
	  cam.x = flr(cam.x + 0.5)
	  cam.y = flr(cam.y + 0.5)
	end
	
-- WORLD shape (uses e.radius if present; bullet has self.radius)
local function elem_shape_world(e)
  local x, y = elem_world_xy(e)

  -- treat any element with radius/r as a circle (center-based)
  local r = e.radius or e.r
  if r then
    return "circ", x, y, r
  end

  -- rect (top-left based)
  local w = (e.size and e.size.w) or 0
  local h = (e.size and e.size.h) or 0
  return "rect", x, y, x + w, y + h
end

local function elems_collide_world(e1, e2)
  if not e1 or not e2 then return false end

  local t1,a1,b1,c1,d1 = elem_shape_world(e1)
  local t2,a2,b2,c2,d2 = elem_shape_world(e2)

  if t1 == "rect" and t2 == "rect" then
    return rects_overlap(a1,b1,c1,d1, a2,b2,c2,d2)
  elseif t1 == "circ" and t2 == "circ" then
    return circ_circ_overlap(a1,b1,c1, a2,b2,c2)
  elseif t1 == "circ" and t2 == "rect" then
    return circ_rect_overlap(a1,b1,c1, a2,b2,c2,d2)
  elseif t1 == "rect" and t2 == "circ" then
    return circ_rect_overlap(a2,b2,c2, a1,b1,c1,d1)
  end

  return false
end
	
	
	
	-- 1) WORLD POS HELPER (drop in once, near get_abs_pos)
	
	-- returns WORLD coords for an element + local offsets
	-- works whether the element is world-space or UI/screen-space
	function get_world_pos(e, ox, oy)
	  cam = cam or {x=0,y=0}
	  ox = ox or 0
	  oy = oy or 0
	
	  local x = (e and e.pos and e.pos.x) or 0
	  local y = (e and e.pos and e.pos.y) or 0
	
	  -- if element is NOT world-space, treat pos as SCREEN and convert to WORLD
	  if not (e and (e.world==true or e.space=="world")) then
	    x += cam.x or 0
	    y += cam.y or 0
	  end
	
	  return x + ox, y + oy
	end
	
	-- call every frame after player moves
function u_camera_follow_player()
  local p = get_el_by_id("player1", "players")          -- however you fetch elements
  local pw, ph = 16, 16               -- player size
  local sw, sh = 480, 270             -- screen size (or your current res)

  -- desired camera so player is centered
  local cx = (p.pos.x + pw*0.5) - sw*0.5
  local cy = (p.pos.y + ph*0.5) - sh*0.5

  -- clamp camera to map bounds (map size in pixels!)
  local maxx = 512 - sw
  local maxy = 512 - sh
  if cx < 0 then cx = 0 elseif cx > maxx then cx = maxx end
  if cy < 0 then cy = 0 elseif cy > maxy then cy = maxy end

  cam.x = flr(cx + 0.5)
  cam.y = flr(cy + 0.5)
end
