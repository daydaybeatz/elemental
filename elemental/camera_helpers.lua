	
	
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

          local ax, ay = get_abs_pos(e)

          -- allow get_abs_pos to return {x=,y=} or { [1]=x,[2]=y }
          if type(ax) == "table" then
            local t = ax
            ax = t.x or t[1]
            ay = t.y or t[2]
          end

          ax = ax or 0
          ay = ay or 0

          -- if element is NOT world-space, treat pos as SCREEN and convert to WORLD
          if not (e and (e.world==true or e.space=="world")) then
            ax += cam.x or 0
            ay += cam.y or 0
          end

          return ax + ox, ay + oy
        end

        -- returns SCREEN coords for an element + local offsets
        -- world elements have camera applied; UI elements ignore camera
        function get_screen_pos(e, ox, oy)
          cam = cam or {x=0,y=0}
          ox = ox or 0
          oy = oy or 0

          local x, y = get_world_pos(e, ox, oy)

          if e and (e.world == true or e.space == "world") then
            x -= cam.x or 0
            y -= cam.y or 0
          end

          return x, y
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


	
	-- add this helper near your other helpers in u_element (next to elem_center_screen)
	local function elem_center_world(e)
	  local wx, wy = elem_world_xy(e)
	  if e.type == "c_button" or e.type == "spr_c_button" then
	    return wx, wy
	  end
	  local w = (e.size and e.size.w) or 0
	  local h = (e.size and e.size.h) or 0
	  return wx + w * 0.5, wy + h * 0.5
	end
	
	function give_id(self, list, prefix)
	  ui_ids = ui_ids or {}
	  list   = list   or {}
	  prefix = prefix or "id_"
	
	  -- if this element was previously registered under some id, clear that slot
	  if self.id and ui_ids[self.id] == self then
	    ui_ids[self.id] = nil
	  end
	
	  local n = #list + 1
	  local new_id = prefix .. tostr(n)
	
	  self.id = new_id
	  self.template = false
	
	  ui_ids[new_id] = self
	  list[n] = self
	
	  return new_id
	end
	
	
	----
	
	function ui_screen_xy(e)
	  cam = cam or {x=0,y=0}
	
	  local ax, ay = get_abs_pos(e)
	
	  -- allow get_abs_pos to return {x=,y=} or { [1]=x,[2]=y }
	  if type(ax) == "table" then
	    local t = ax
	    ax = t.x or t[1]
	    ay = t.y or t[2]
	  end
	
	  ax = ax or 0
	  ay = ay or 0
	
	  if e and (e.world == true or e.space == "world") then
	    ax -= cam.x or 0
	    ay -= cam.y or 0
	  end
	
	  -- match d_element() visual offsets
	  if e and e.hover_anim_type then
	    ax += e.hover_offset_x or 0
	    ay += e.hover_offset_y or 0
	  end
	
	  if e and e.element_offset then
	    ax += e.element_offset.x or 0
	    ay += e.element_offset.y or 0
	  end
	
	  -- match d_element() custom draw offset base (dx,dy)
	  if e and e.draw_offset then
	    ax += e.draw_offset.x or 0
	    ay += e.draw_offset.y or 0
	  end
	
	  return ax, ay
	end
	
	function ui_anchor_xy(e)
	  local x, y = ui_screen_xy(e)
	
	  if not e then return x, y end
	
	  if e.type == "c_button" or e.type == "spr_c_button" then
	    return x, y
	  end
	
	  local w = (e.size and e.size.w) or 0
	  local h = (e.size and e.size.h) or 0
	  return x + w * 0.5, y + h * 0.5
	end
	
	
	
	-- auto grid based on parent.size and child sizes
	
	-- new grid: arrange = {parent_id, pad_x, pad_y, [static_row], [static_col]}
	-- auto-chosen row/col are based on index of VISIBLE children
	-- and the parent's width vs child size.
	-- helper: auto grid placement
	
	-- arrange = { parent_id, pad_x, pad_y, [static_row], [static_col] }
	function auto_arrange(e)
	    if not e.arrange then return end
	    if not ui or not ui[e.page] then return end
	
	    local arr       = e.arrange
	    local parent_id = arr[1]
	    if not parent_id then return end
	
	    local pad_x      = arr[2] or 0
	    local pad_y      = arr[3] or 0
	    local static_row = arr[4]
	    local static_col = arr[5]
	
	    -- 1) collect all siblings on this page that share this arrange parent_id
	    local page_list = ui[e.page]
	    local group = {}
	    for i = 1, #page_list do
	        local c = page_list[i]
	        if c.visible ~= false and c.arrange then
	            local ca = c.arrange
	            if ca and ca[1] == parent_id then
	                group[#group+1] = c
	            end
	        end
	    end
	    if #group == 0 then return end
	
	    ------------------------------------------------
	    -- 2) choose layout anchor (from arrange id)
	    ------------------------------------------------
	    local layout_parent = nil
	
	    -- ALWAYS prefer the id given in arrange[1]
	    if ui_ids and ui_ids[parent_id] then
	        layout_parent = ui_ids[parent_id]
	    elseif e.parent then
	        -- fallback: real parent if id wasn't found
	        layout_parent = e.parent
	    end
	
	    local parent_x, parent_y = 0, 0
	    local parent_w           = 480 -- screen width fallback
	
	    if layout_parent then
	        -- anchor is ABSOLUTE screen position of the arrange target
	        parent_x, parent_y = get_abs_pos(layout_parent)
	        if layout_parent.size and layout_parent.size.w then
	            parent_w = layout_parent.size.w
	        end
	    end
	
	    ------------------------------------------------
	    -- 3) compute cell size (max of group + padding)
	    ------------------------------------------------
	    local cell_w, cell_h = 0, 0
	    for i = 1, #group do
	        local c = group[i]
	        if c.size then
	            if c.size.w > cell_w then cell_w = c.size.w end
	            if c.size.h > cell_h then cell_h = c.size.h end
	        end
	    end
	
	    cell_w = cell_w + pad_x
	    cell_h = cell_h + pad_y
	
	    if cell_w <= 0 then cell_w = 1 end
	    if cell_h <= 0 then cell_h = 1 end
	
	    local cols = flr((parent_w - pad_x) / cell_w)
	    if cols < 1 then cols = 1 end
	
	    ------------------------------------------------
	    -- 4) assign row/col + final position
	    ------------------------------------------------
	    for idx = 1, #group do
	        local c  = group[idx]
	        local ca = c.arrange
	
	        local crow = ca[4]
	        local ccol = ca[5]
	
	        local row, col
	
	        -- fixed position if both row+col provided
	        if crow and ccol then
	            row = crow
	            col = ccol
	        else
	            -- auto position based on index
	            local k = idx - 1
	            row = flr(k / cols) + 1
	            col = (k % cols) + 1
	        end
	
	        -- base WORLD-space grid position, anchored to arrange-id
	        local gx = parent_x + pad_x + (col - 1) * cell_w
	        local gy = parent_y + pad_y + (row - 1) * cell_h
	
	        if c.parent then
	            -- convert world-space back to local relative to c.parent
	            local px, py = get_abs_pos(c.parent)
	            c.pos.x = gx - px
	            c.pos.y = gy - py
	        else
	            -- no parent: keep world-space
	            c.pos.x = gx
	            c.pos.y = gy
	        end
	    end
	end
