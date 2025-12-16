	--collision()
	function col(a,b)
	if 		a.x+a.w<b.x		 then 
	return false end
	if  a.x>b.x+b.w then 
	return false end
	
	if 		a.x+a.w<b.x		 then 
	return false end
	if  a.x>b.x+b.w then 
	return false end
	
	if 		a.y+a.h<b.y		 then 
	return false end
	if  a.y>b.y+b.h then 
	return false end
	
	if 		a.y+a.h<b.y		 then 
	return false end
	if  a.y>b.y+b.h then 
	return false end
	--sfx(0)
	return true 
	
	end
	
	---
	function col2(a, b)
	    -- Calculate the distance between the centers of the two objects
	    local dx = a.x - b.x
	    local dy = a.y - b.y
	    local distance = sqrt(dx * dx + dy * dy)
	    
	    -- Check if the distance is less than the sum of the radii
	    return distance < (a.w + b.w)
	end
	--
	
	-- bar(
	--   val, max, x, y, col, centered,
	--   fixed_width, fixed_height,
	--   bg_sprites,        -- {idle_bg, hover_bg, clicked_bg}
	--   fill_sprites,      -- {idle_fill, hover_fill, clicked_fill}
	--   state              -- "idle" | "hover" | "clicked" | 1..3 (optional, default idle)
	-- )
	-- bar(
	--   val, max, x, y, col, centered,
	--   fixed_width, fixed_height,
	--   bg_sprites,    -- {idle, hover, clicked}
	--   fill_sprites,  -- {idle, hover, clicked}
	--   state,         -- "idle" | "hover" | "clicked" | 1..3
	--   draw,          -- function(dx, dy, w, h)
	--   clipped,       -- true = clip draw() to bar fill area
	--   draw_offset    -- {x=0,y=0} applied to dx,dy
	-- )
	-- bar(
	--   val, max, x, y, col, centered,
	--   fixed_width, fixed_height,
	--   bg_sprites,    -- {idle, hover, clicked}
	--   fill_sprites,  -- {idle, hover, clicked}
	--   state          -- "idle" | "hover" | "clicked" | 1..3
	-- )
	function bar(val, max, x, y, col, centered, fixed_width, fixed_height,
	             bg_sprites, fill_sprites, state)
	
	    if not max or max <= 0 then return end
	    val = mid(val or 0, 0, max)
	
	    local w = fixed_width  or 50
	    local h = fixed_height or 5
	
	    ------------------------------------------------
	    -- normalize color table
	    ------------------------------------------------
	    local base = 24
	    if type(col) == "table" then
	        local c0 = col[1] or col[2] or base
	        col = {
	            col[1] or c0,        -- fill
	            col[2] or c0,        -- fill outline
	            col[3] or (c0-1),    -- bg
	            col[4] or (c0+1)     -- bg outline
	        }
	    else
	        local c0 = col or base
	        col = {c0, c0, c0-1, c0+1}
	    end
	
	    ------------------------------------------------
	    -- choose sprite index based on state
	    ------------------------------------------------
	    local idx = 1
	    if type(state) == "string" then
	        if state == "hover"     then idx = 2
	        elseif state == "clicked" then idx = 3 end
	    elseif type(state) == "number" then
	        idx = mid(flr(state), 1, 3)
	    end
	
	    local bg_spr   = bg_sprites   and bg_sprites[idx]
	    local fill_spr = fill_sprites and fill_sprites[idx]
	
	    ------------------------------------------------
	    -- base rect position (top-left)
	    ------------------------------------------------
	    local x0 = centered and (x - w/2) or x
	    local y0 = y
	
	    ------------------------------------------------
	    -- background: sprite frame or plain rect
	    ------------------------------------------------
	    local use_bg_spr = (bg_spr ~= nil)
	    if use_bg_spr then
	        -- spr_container(x, y, w, h, s)
	        spr_container(bg_spr, x0, y0, w, h )
	    else
	        rectfill(x0, y0, x0 + w, y0 + h, col[3])
	        rect    (x0, y0, x0 + w, y0 + h, col[4])
	    end
	
	    ------------------------------------------------
	    -- fill area (inner rect)
	    ------------------------------------------------
	    local inset = use_bg_spr and 1 or 0
	    local fx0   = x0 + inset
	    local fy0   = y0 + inset
	    local fw    = w  - inset*2
	    local fh    = h  - inset*2
	
	    local fill_w = flr((val / max) * fw)
	    if fill_w < 0 then fill_w = 0 end
	
	    local fx1, fx2
	    if centered then
	        local cx = fx0 + fw/2
	        fx1 = cx - fill_w/2
	        fx2 = cx + fill_w/2
	    else
	        fx1 = fx0
	        fx2 = fx0 + fill_w
	    end
	
	    if fill_w > 0 then
	        if fill_spr then
	            spr_container(fill_spr, fx1, fy0, fx2 - fx1, fh)
	        else
	            rectfill(fx1, fy0, fx2, fy0 + fh, col[1])
	            rect    (fx1, fy0, fx2, fy0 + fh, col[2])
	        end
	    end
	end
	
	
	
	
	
	
	--		bar(health, max_health, x, y, {24,7}, false, 100, 12)
			--draw bar for health/etc.
	
	--to do:
	--  i want the color arg to take a table {1,2,3,4,5,6} 
	--  col,outline,hover col,hover outline, clicked col, clicked outline, 
	--  and 3 extra args : "animation_type", particle size, speed. 
	---
	
	---
	--flash_colors()
	-- Flash colors 8, 9, 10 using palette colors 2, 3, 4 at 4 Hz
	
	--fpal({8, 9, 10}, {2, 3, 4}, 4)
	
	function fpal(targets, replacements, speed)
	    local step = flr(time() * speed) % #replacements
	    for i = 1, #targets do
	        local from = targets[i]
	        local to = replacements[(i + step - 1) % #replacements + 1]
	        pal(from, to)
	    end
	end
	
	--animate_sprite()
	--exmaple:
	--spr(animate({1,2,3,2},1),x,y)
	
	function animate(frames, speed)
	    local index = flr(time() * speed) % #frames + 1
	    return frames[index]
	end
	
	-- f_print(text, x, y, base_col, speed, colors)
	-- example:
	--   f_print("RELOAD!", 9, 13, 7, 0.5, {7, 8})
	
	function f_print(txt, x, y, col, speed, colors)
	    -- fallback defaults
	    if not speed or speed <= 0 then speed = 1 end
	    if not col then col = 7 end
	
	    -- if no colors given, just flash between base color and black
	    colors = colors or {col, 0}
	    local n = #colors
	    if n == 0 then colors = {col} n = 1 end
	
	    -- use time to pick color index
	    -- t() is Picotron/PICO-8 time in seconds
	    local tt  = t()  -- or your own global time counter
	    local idx = flr((tt * speed) % n) + 1
	    local c   = colors[idx] or col
	
	    print(txt, x, y, c)
	end
	
	
	
	function spr_container(s, x, y, w, h)
	    s = get_spr(s)
	    local sw, sh = s:attribs()
	
	    -- each 9-slice cell size
	    local slice_w = sw \ 3
	    local slice_h = sh \ 3
	
	    -- inner (stretchable) area size
	    local inner_w = max(0, w - slice_w * 2)
	    local inner_h = max(0, h - slice_h * 2)
	
	    -- build slices table once
	    local slices = {}
	    for _y = 0, 2 do
	        local row = {}
	        for _x = 0, 2 do
	            local slice = userdata("u8", slice_w, slice_h)
	            s:blit(slice, _x*slice_w, _y*slice_h, 0, 0, slice_w, slice_h)
	            add(row, slice)
	        end
	        add(slices, row)
	    end
	
	    -- corners (x,y is now TOP-LEFT of whole box)
	    -- top-left
	    spr(slices[1][1], x, y)
	    -- top-right
	    spr(slices[1][3], x + slice_w + inner_w, y)
	    -- bottom-left
	    spr(slices[3][1], x, y + slice_h + inner_h)
	    -- bottom-right
	    spr(slices[3][3], x + slice_w + inner_w, y + slice_h + inner_h)
	
	    -- TOP edge
	    clip(x + slice_w, y, inner_w, slice_h)
	    for _x = 0, inner_w, slice_w do
	        spr(slices[1][2], x + slice_w + _x, y)
	    end
	
	    -- BOTTOM edge
	    clip(x + slice_w, y + slice_h + inner_h, inner_w, slice_h)
	    for _x = 0, inner_w, slice_w do
	        spr(slices[3][2], x + slice_w + _x, y + slice_h + inner_h)
	    end
	
	    -- LEFT edge
	    clip(x, y + slice_h, slice_w, inner_h)
	    for _y = 0, inner_h, slice_h do
	        spr(slices[2][1], x, y + slice_h + _y)
	    end
	
	    -- RIGHT edge
	    clip(x + slice_w + inner_w, y + slice_h, slice_w, inner_h)
	    for _y = 0, inner_h, slice_h do
	        spr(slices[2][3], x + slice_w + inner_w, y + slice_h + _y)
	    end
	
	    -- CENTER fill
	    clip(x + slice_w, y + slice_h, inner_w, inner_h)
	    for _x = 0, inner_w, slice_w do
	        for _y = 0, inner_h, slice_h do
	            spr(slices[2][2], x + slice_w + _x, y + slice_h + _y)
	        end
	    end
	
	    clip()
	end
	
	
	--rotate_sprite
	function rotate_sprite(sprite,cx,cy,sx,sy,rot)
		sx = sx and sx or 1
		sy = sy and sy or 1
		rot = rot and rot or 0
		local tex = get_spr(sprite)
		local dx,dy = tex:width()*sx,tex:height()*sy
		local quad = {
			{x=0, y=0, u=0, v=0},
			{x=dx, y=0, u=tex:width()-0.001, v=0},
			{x=dx, y=dy, u=tex:width()-0.001, v=tex:height()-0.001},
			{x=0, y=dy, u=0, v=tex:height()-0.001},
		}
		local c,s = cos(rot),-sin(rot)
		local w,h = (dx-1)/2, (dy-1)/2
		for _,v in pairs(quad) do
			local x,y = v.x-w,v.y-h
			v.x = c*x-s*y
			v.y = s*x+c*y	
		end
		tquad(quad, tex, cx, cy)
	end
	
	
	-- set_color(pal_index, {r,g,b})
	-- r,g,b are 0???255
	function set_color(idx, rgb)
	    local r = rgb[1]
	    local g = rgb[2]
	    local b = rgb[3]
	
	    -- pack into 0xRRGGBB
	    local hex = r * 0x10000 + g * 0x100 + b
	
	    -- picotron-style pal call
	    pal(idx, hex, 2)
	end



-----



	
	local function sample_color(colors, t)
	    if not colors or #colors == 0 then
	        return 7
	    end
	    if t <= 0 then return colors[1] end
	    if t >= 1 then return colors[#colors] end
	    local seg = (#colors - 1) * t
	    local i   = flr(seg) + 1
	    if i < 1 then i = 1 end
	    if i > #colors then i = #colors end
	    return colors[i]
	end
	
	---
	local two_pi = 6.2831853
	---
	
	function lerp(a,b,t)
	    return a+(b-a)*t
	end
	
	function clamp(v,a,b)
	    if v<a then return a end
	    if v>b then return b end
	    return v
	end
	
	-- internal helper: normalize target to a list of elements
	-- target can be:
	--   "id"           -> element with that id
	--   element table  -> {element}
	--   list of elems  -> list itself
	local function _resolve_targets(target)
	    local out = {}
	
	    if not target then
	        return out
	    end
	
	    local t = type(target)
	
	    if t == "string" then
	        -- treat as id
	        if ui_ids and ui_ids[target] then
	            add(out, ui_ids[target])
	        end
	
	    elseif t == "table" then
	        -- single element? (has .page or .type)
	        if target.page or target.type or target.id then
	            add(out, target)
	        else
	            -- assume it's already a list of elements
	            for e in all(target) do
	                add(out, e)
	            end
	        end
	    end
	
	    return out
	end
	
	local function rand_int_range(a,b)
	    if not a then return 0 end
	    if not b then return a end
	    if a > b then a,b = b,a end
	    return flr(rnd(b - a + 1)) + a
	end
	
	function get_data(target, field, default)
	-- takes str_id and a data variable string name and returns its value
	-- get_data("dry_dock", "upkeep")  -> value or nil
	-- get_data("dry_dock", "upkeep", 0) -> value or default
	-- get_data("dry_dock", "upkeep", 0)
	-- get_data(get_all("locations"), "upkeep", 0) -> {v1, v2, ...}
	    local elems = _resolve_targets(target)
	    if #elems == 0 then
	        return default
	    end
	
	    -- single element: return scalar
	    if #elems == 1 then
	        local e = elems[1]
	        e.data = e.data or {}
	        local v = e.data[field]
	        if v == nil then return default end
	        return v
	    end
	
	    -- multiple elements: return list of values
	    local result = {}
	    for e in all(elems) do
	        e.data = e.data or {}
	        local v = e.data[field]
	        if v == nil then
	            v = default
	        end
	        add(result, v)
	    end
	    return result
	end
	
	
	
	function get_all(page)
	-- returns a flat list of element tables on that page
	    if not ui or not ui[page] then
	        return {}
	    end
	
	    local list = {}
	    for e in all(ui[page]) do
	        add(list, e)
	    end
	    return list
	end
	
	function set_data(target, field, value)
	    if not target or not field then return end
	
	    local elems = nil
	
	    -- string: element id or page name
	    if type(target) == "string" then
	        if ui_ids and ui_ids[target] then
	            elems = { ui_ids[target] }
	        elseif ui and ui[target] then
	            elems = ui[target]          -- treat as page list
	        else
	            return
	        end
	
	    -- table: single element or list of elements
	    elseif type(target) == "table" then
	        if target.page or target.type then
	            elems = { target }          -- single element
	        else
	            elems = target              -- assume list
	        end
	    else
	        return
	    end
	
	    if not elems or #elems == 0 then return end
	
	    -- single element: return the value
	    if #elems == 1 then
	        local e = elems[1]
	        e.data = e.data or {}
	        e.data[field] = value
	        return value
	    end
	
	    -- multiple elements: return list
	    local result = {}
	    for i=1,#elems do
	        local e = elems[i]
	        if e then
	            e.data = e.data or {}
	            e.data[field] = value
	            result[#result+1] = value
	        end
	    end
	
	    return result
	end
	
	
	function mod_data(target, field, delta, default)
	--takes str_id and variable string name, 
	-- mod_data("dry_dock", "upkeep", 5)
	-- mod_data(get_all("locations"), "upkeep", -2)
	-- if the field doesn't exist, it starts from default
	    local elems = _resolve_targets(target)
	    if #elems == 0 then
	        return nil
	    end
	if not default then default=0 end
	
	    -- single element: return scalar
	    if #elems == 1 then
	        local e = elems[1]
	        e.data = e.data or {}
	        local old = e.data[field]
	        if type(old) ~= "number" then old = default end
	        local new = old + delta
	        e.data[field] = new
	        return new
	    end
	
	    -- multiple elements: return list
	    local result = {}
	    for e in all(elems) do
	        e.data = e.data or {}
	        local old = e.data[field]
	        if type(old) ~= "number" then old = 0 end
	        local new = old + delta
	        e.data[field] = new
	        add(result, new)
	    end
	
	    return result
	end
	
	function total_variable(page,var_str)
	--takes page with multiple elements and gets their var_str and adds them up
	    -- get all elements on this page
	    local elems = get_all(page)
	
	    -- get variable for each element as a list
	    local var_str = get_data(elems, tostr(var_str), 0)
	
	    -- sum them
	    local sum = 0
	    for i=1,#var_str do
	        sum += var_str[i]
	    end
	
	    return sum
	end


----


	
	--  helper for draggables -- 
	--  move_to_slot(nil, "equipment_1")
	function move_to_slot(src, dest_slot_id)
	-- expects:
	--  ui_ids[id] to look up elements
	--  slots have: type == "slot", slot.held = element or nil
	--  items have: e.slot = slot or nil (optional, if you???re tracking it)
	
	    -- if no src given, or "active" given, use last active item id
	    if src == nil or src == "active" then
	        src = ui_active_item_id
	    end
	
	    if not src then
	        -- nothing selected, nothing to move
	        return
	    end
	
	    -- resolve source element
	    local src_elem
	    if type(src) == "string" then
	        src_elem = ui_ids[src]
	    else
	        -- allow passing the element itself too
	        src_elem = src
	    end
	    if not src_elem then return end
	
	    -- resolve destination slot
	    local dest_slot = ui_ids[dest_slot_id]
	    if not dest_slot or dest_slot.type ~= "slot" then
	        return
	    end
	
	    ---------------------------------------
	    -- detach from current slot, if any
	    ---------------------------------------
	    if src_elem.slot and src_elem.slot.held == src_elem then
	        src_elem.slot.held = nil
	    end
	
	    ---------------------------------------
	    -- move into destination slot
	    ---------------------------------------
	    dest_slot.held  = src_elem
	    src_elem.slot   = dest_slot
	
	    -- center item inside the slot visually
	    local sx, sy = get_abs_pos(dest_slot)
	    local sw     = dest_slot.size and dest_slot.size.w or 8
	    local sh     = dest_slot.size and dest_slot.size.h or 8
	    local iw     = src_elem.size and src_elem.size.w or 8
	    local ih     = src_elem.size and src_elem.size.h or 8
	
	    src_elem.pos.x = sx + (sw - iw/2) 
	    src_elem.pos.y = sy + (sh - ih/2) 
	end


----


	---
	--save/load game
	-- Persistent save setup
	function init_save()
	save_dir = "/appdata/MyShooterGame"
	save_file = "save1.pod"
	player_vars = { high_score = 0 }
	end
	
	function save_game()
	    mkdir(save_dir)
	    store(save_dir.."/"..save_file, player_vars)
	end
	
	function load_game()
	    local data = fetch(save_dir.."/"..save_file)
	    if data then
	        player_vars = data
	    end
	end
	
		------------------------------------------------------------
	------------------------------------------------------------
	-- get_arg(id, key)
	-- returns the raw field from an element by id
	--   get_arg("dialogue_1", "label") -> e.label
	--   get_arg("stats_bg",   "pos")   -> e.pos
	------------------------------------------------------------
	function get_arg(id, key)
	    if not ui_ids then return nil end
	
	    local e = ui_ids[id]
	    if not e then
	        -- optional debug
	        -- printh("get_arg: no element with id "..tostr(id))
	        return nil
	    end
	
	    return e[key]
	end
	
	
	function mod_val(tbl, k, delta)
	    if tbl[k] == nil then
	        tbl[k] = delta
	    else
	        tbl[k] += delta
	    end
	end
	
	local function str_in_list(list, s)
	    for i=1,#list do
	        if list[i] == s then return true end
	    end
	    return false
	end
	
	-- Animation-aware page toggler:
	-- open/close is now handled by page state + wipe/slide
	function toggle_string(list, page)
	    ui_page_state = ui_page_state or {}
	    local state = ui_page_state[page]
	
	    -- infer state if needed
	    if not state then
	        if str_in_list(list, page) then
	            state = "open"
	        else
	            state = "closed"
	        end
	    end
	
	    if state == "closed" then
	        -- -> OPEN
	        ui_page_state[page] = "opening"
	
	        if not str_in_list(list, page) then
	            local top = list[#list]
	
	            if top then
	                -- insert page just under current top
	                list[#list]   = page
	                list[#list+1] = top
	            else
	                -- nothing yet, just add
	                list[#list+1] = page
	            end
	        end
	
	    elseif state == "open" then
	        ui_page_state[page] = "closing"
	
	    elseif state == "opening" then
	        ui_page_state[page] = "closing"
	
	    elseif state == "closing" then
	        ui_page_state[page] = "opening"
	    end
	end
	
	
	-- usage:
	--   toggle_string(ap, "main")
	--   toggle_string(ap, "main", "inv")
	
	
	-- simple wrapper: one page only
	function toggle_strings(list, layer, page)
	
	    -- allow calling without layer too:
	    -- toggle_strings(ap, "page")
	    if type(layer) == "string" and page == nil then
	        toggle_string(list, layer)
	    else
	        toggle_string(list, layer, page)
	    end
	end
	
	-- toggle an element's visibility by id
	-- usage:
	--   toggle_element("my_id")                 -- uses ap[1]
	--   toggle_element("my_id", 2)             -- uses ap[2]
	--   toggle_element("my_id", "some_page")   -- explicit page name
	--   toggle_element("my_id", 2, "some_page")
	
	------------------------------------------------------------
	-- toggle_element_anim(id)
	-- Animation-aware element toggler (like toggle_string).
	-- Handles wipe/slide and maintains element _state.
	------------------------------------------------------------
	-- animation-aware element toggler
	function toggle_element(str_id)
	    if not ui_ids then return end
	
	    local e = ui_ids[str_id]
	    if not e then return end
	
	    ui_elem_state = ui_elem_state or {}
	
	    local state = ui_elem_state[e.id]
	    if not state then
	        if e.visible == false then
	            state = "closed"
	        else
	            state = "open"
	        end
	    end
	
	    if state == "closed" then
	        -- CLOSED -> OPENING
	        e.visible = true
	        ui_elem_state[e.id] = "opening"
	
	        if e.wipe then
	            e.wipe.mode = "opening"
	            e.wipe.t    = 0
	        end
	
	        if e.slide then
	            local s = e.slide
	            e.slide_mode = "opening"
	            e.slide_t    = 0
	            if s then
	                e.pos.x = s[1]
	                e.pos.y = s[2]
	            end
	        end
	
	    elseif state == "open" then
	        -- OPEN -> CLOSING
	        ui_elem_state[e.id] = "closing"
	
	        if e.wipe then
	            e.wipe.mode = "closing"
	            e.wipe.t    = 0
	        end
	
	        if e.slide then
	            local s = e.slide
	            e.slide_mode = "closing"
	            e.slide_t    = 0
	            if s then
	                e.pos.x = s[3]
	                e.pos.y = s[4]
	            end
	        end
	
	    elseif state == "opening" then
	        -- reverse mid-animation: opening -> closing
	        ui_elem_state[e.id] = "closing"
	
	        if e.wipe then
	            e.wipe.mode = "closing"
	            e.wipe.t    = 1 - (e.wipe.t or 0)
	        end
	
	        if e.slide then
	            e.slide_mode = "closing"
	            e.slide_t    = 1 - (e.slide_t or 0)
	        end
	
	    elseif state == "closing" then
	        -- reverse mid-animation: closing -> opening
	        e.visible = true
	        ui_elem_state[e.id] = "opening"
	
	        if e.wipe then
	            e.wipe.mode = "opening"
	            e.wipe.t    = 1 - (e.wipe.t or 0)
	        end
	
	        if e.slide then
	            e.slide_mode = "opening"
	            e.slide_t    = 1 - (e.slide_t or 0)
	        end
	    end
	
	    return ui_elem_state[e.id]
	end
	
	
	
	
	
	
	
	function print_data(self, mode, x, y, line_space, colors, order)
	-- self.data  = { power=100, value=50, speed=3 }
	-- self.order = { "power", "value", "speed" }
	-- colors     = { 8, 10, 11 }
	
	-- print_data(self, x, y, line_space, colors, mode)
	-- mode: "relative" (default) = offsets from mouse
	--       "fixed"              = absolute screen position
	    local mx, my = mouse()
	
	    x          = x or 0
	    y          = y or 0
	    line_space = line_space or 6
	    mode       = mode or "relative"
	
	    local base_x, base_y
	    if mode == "fixed" then
	        base_x = x
	        base_y = y
	    else
	        base_x = mx + x
	        base_y = my + y
	    end
	
	    -- helper: "food_production" -> "food production"
	    local function key_to_label(k)
	        local label = ""
	        for i = 1, #k do
	            local ch = sub(k, i, i)
	            if ch == "_" then
	                ch = " "
	            end
	            label ..= ch
	        end
	        return label
	    end
	
	    local i          = 0
	    local order_list = order or self.order   -- prefer arg if given
	
	    if order_list and #order_list > 0 then
	        -- STRICT: use numeric indices, never pairs()
	        for idx = 1, #order_list do
	            local key = order_list[idx]
	            local v   = self.data and self.data[key]
	            if v ~= nil then
	                local c = 7
	                if colors and #colors > 0 then
	                    local ci = idx
	                    if ci > #colors then ci = #colors end
	                    c = colors[ci]
	                end
	
	                local label = key_to_label(key)
	
	                print(
	                    label..": "..tostr(v),
	                    base_x,
	                    base_y + i * line_space,
	                    c
	                )
	                i += 1
	            end
	        end
	    else
	        -- fallback: arbitrary order
	        for key, v in pairs(self.data or {}) do
	            local c = 7
	            if colors and #colors > 0 then
	                local ci = (i % #colors) + 1
	                c = colors[ci]
	            end
	
	            local label = key_to_label(key)
	
	            print(
	                label..": "..tostr(v),
	                base_x,
	                base_y + i * line_space,
	                c
	            )
	            i += 1
	        end
	    end
	end
	
	
				-- ui screen shake state
	ui_shake_t   = 0      -- remaining frames
	ui_shake_amt = 0      -- pixel strength
	
	-- call this from game or UI: ui_shake(amt, duration)
	function shake(amt, dur)
	    ui_shake_amt = amt or 2           -- how far camera can move in pixels
	    local d      = dur or 15          -- how many frames
	
	    -- keep the *strongest / longest* if called repeatedly
	    if d > ui_shake_t then
	        ui_shake_t = d
	    end
	end
	


----

	
	-- get player by id string
	function get_player_by_id(id)
	  return (ui_ids and ui_ids[id]) or nil
	end



---




	-- call once per frame
	function u_sfx_gate()
	  if not sfx_gate then return end
	  for ch,g in pairs(sfx_gate) do
	    if g.t and g.t > 0 then g.t -= 1 end
	    if g.t <= 0 then g.id=nil g.t=0 end
	  end
	end
	
	-- play_sfx_once(id, ch, len, off)
	-- only triggers if that same sfx isn't already playing on that channel
	-- (channel-based gate; simplest + reliable)
	sfx_gate = sfx_gate or {}
	
	function sfx2(id, ch, len, off)
	  ch = ch or 0
	  sfx_gate[ch] = sfx_gate[ch] or {id=nil, t=0}
	
	  local g = sfx_gate[ch]
	
	  -- still "busy" with same sfx? don't retrigger
	  if g.t > 0 and g.id == id then return false end
	
	  -- start it
	  sfx(id, ch, len, off)
	
	  -- estimate busy time (frames). if you pass len, use it; otherwise default small gate.
	  -- (len is in notes/steps in pico/picotron style; using it as a rough frame gate)
	  g.id = id
	  g.t  = (len and max(1, len*2)) or 12
	
	  return true
	end


----
	-------
	-------
	
	function shake_element(str_id, amt, duration)
	    if not ui_ids or not ui_ids[str_id] then return end
	
	    local e = ui_ids[str_id]
	    amt      = amt      or 2     -- pixels
	    duration = duration or 10    -- frames
	
	    e.shake = e.shake or {}
	
	    -- if already shaking, keep the stronger/longer one
	    e.shake.amt = max(e.shake.amt or 0, amt)
	    e.shake.t   = max(e.shake.t   or 0, duration)
	end
	

----

	------------------------------------------------------------
	-- INTERNAL HELPERS (wont need these very often)
	------------------------------------------------------------
	-- call AFTER init_ui() and all your i_element() calls
	function init_slide_closed(str_id)
	    if not ui_ids or not ui_ids[str_id] then return end
	
	    local e = ui_ids[str_id]
	    if not e or not e.slide then return end
	
	    local s = e.slide
	    ui_elem_state = ui_elem_state or {}
	
	    -- mark as managed + closed for toggle_element / u_element
	    ui_elem_state[e.id] = "closed"
	
	    -- visually hidden
	    e.visible    = false
	    e.slide_mode = "closed"
	    e.slide_t    = 1
	
	    -- snap to OFF position = slide "from" coords (s[1], s[2])
	    e.pos = e.pos or {x = 0, y = 0}
	    e.pos.x = s[1]
	    e.pos.y = s[2]
	
	    -- if you also use wipe, lock that closed too
	    if e.wipe then
	        e.wipe.mode = "closed"
	        e.wipe.t    = 1
	    end
	end



---

	
	-- draw a screen-space grid using line()
	-- draw_grid(x_pct, y_pct, {xcol,ycol,x_every,y_every})
	-- - screen assumed 480x270
	-- - border is always rect(1,1,479,269)
	-- - x_pct/y_pct are spacing as a % of usable area (478x268)
	--   ex: x_pct=10 -> vertical line every ~47 px
	-- - x_every/y_every: if provided (>0), draw only every Nth line in that axis
	function draw_grid(x_pct, y_pct, cfg)
	  cfg = cfg or {}
	
	  -- cfg = { xcol1, ycol1, xcol2, ycol2 }
	  local xcol1 = cfg[1] or 8
	  local ycol1 = cfg[2] or 12
	  local xcol2 = cfg[3] or xcol1
	  local ycol2 = cfg[4] or ycol1
	
	  -- border
	  color(7)
	  rect(1,1,479,269)
	
	  local w = 478
	  local h = 268
	
	  local sx = flr(((x_pct or 10) * w) / 100)
	  local sy = flr(((y_pct or 10) * h) / 100)
	  if sx < 1 then sx = 1 end
	  if sy < 1 then sy = 1 end
	
	  -- vertical lines (alternate colors, no skipping)
	  local n = 0
	  for x = 1+sx, 479-sx, sx do
	    n += 1
	    color((n % 2 == 0) and xcol2 or xcol1)
	    line(x, 1, x, 269)
	  end
	
	  -- horizontal lines (alternate colors, no skipping)
	  n = 0
	  for y = 1+sy, 269-sy, sy do
	    n += 1
	    color((n % 2 == 0) and ycol2 or ycol1)
	    line(1, y, 479, y)
	  end
	end


----


	--
	
	ui_page_state = ui_page_state or {}
	
	-- compute absolute slide endpoints once from layout + slide_cfg
	function ensure_slide_setup(e)
	    if not e.slide_cfg then return end
	    if e.slide_abs then return end
	
	    -- base (arranged, parented) "open" position
	    local bx, by = get_abs_pos(e)
	    local s = e.slide_cfg
	    local dx1, dy1, dx2, dy2 = s[1] or 0, s[2] or 0, s[3] or 0, s[4] or 0
	
	    if e.arrange then
	        -- relative to arranged position
	        e.slide_abs = {
	            bx + dx1, by + dy1,  -- closed
	            bx + dx2, by + dy2   -- open
	        }
	    else
	        -- absolute or "0 means use base"
	        local x1 = (dx1 ~= 0) and dx1 or bx
	        local y1 = (dy1 ~= 0) and dy1 or by
	        local x2 = (dx2 ~= 0) and dx2 or bx
	        local y2 = (dy2 ~= 0) and dy2 or by
	        e.slide_abs = {x1, y1, x2, y2}
	    end
	
	    -- if mode not set yet, infer from visibility
	    if not e.slide_mode then
	        e.slide_mode = e.visible and "open" or "closed"
	        e.slide_t    = (e.slide_mode == "open") and 1 or 0
	    end
	end
	
	-- advance slide based on element state (and optionally page opening/closing)
	function step_slide(e, opening, closing, page_all_open_done_ref, page_all_close_done_ref)
	    if not e.slide_cfg then return end
	
	    ensure_slide_setup(e)
	    local s = e.slide_abs
	
	    -- page open/close can kick off slide if no explicit element state
	    if opening and (e.slide_mode == "closed" or e.slide_mode == nil) then
	        e.slide_mode = "opening"
	        e.slide_t    = 0
	    elseif closing and (e.slide_mode == "open" or e.slide_mode == nil) then
	        e.slide_mode = "closing"
	        e.slide_t    = 0
	    end
	
	    -- element toggle (toggle_element) will also set slide_mode/t
	    if e.slide_mode == "opening" then
	        local spd = e.slide_speed or 0.1
	        e.slide_t += spd
	        if e.slide_t >= 1 then
	            e.slide_t    = 1
	            e.slide_mode = "open"
	        end
	    elseif e.slide_mode == "closing" then
	        local spd = e.slide_speed or 0.1
	        e.slide_t += spd
	        if e.slide_t >= 1 then
	            e.slide_t    = 1
	            e.slide_mode = "closed"
	        end
	    end
	
	    local t
	    if e.slide_mode == "opening" then
	        t = e.slide_t
	    elseif e.slide_mode == "closing" then
	        t = 1 - e.slide_t
	    elseif e.slide_mode == "open" then
	        t = 1
	    else -- "closed" or nil
	        t = 0
	    end
	
	    -- drive position from absolute endpoints
	    e.pos.x = lerp(s[1], s[3], t)
	    e.pos.y = lerp(s[2], s[4], t)
	
	    -- let page-state know if we're done
	    if opening and page_all_open_done_ref then
	        if e.slide_mode ~= "open" then
	            page_all_open_done_ref[1] = false
	        end
	    end
	    if closing and page_all_close_done_ref then
	        if e.slide_mode ~= "closed" then
	            page_all_close_done_ref[1] = false
	        end
	    end
	end
	
	------------------------------------------------------------
	-- BULLNOSE RECT HELPERS (diagonal/cut corners)
	-- usage matches rrect/rrectfill:
	--   bnrectfill(x, y, w, h, b, col)
	--   bnrect(x, y, w, h, b, col)
	-- where:
	--   (x,y) is top-left
	--   (w,h) is width/height
	--   b     is chamfer distance in pixels
	------------------------------------------------------------
	function bnrectfill(x, y, w, h, b, col)
	    if not b or b <= 0 then
	        rectfill(x, y, x + w, y + h, col)
	        return
	    end
	
	    local x1, y1 = x, y
	    local x2, y2 = x + w, y + h
	
	    local maxb = flr(min(w, h) / 2)
	    if b > maxb then b = maxb end
	
	    for yy = y1, y2 do
	        local dy_top = yy - y1
	        local dy_bot = y2 - yy
	        local cut = 0
	
	        if dy_top < b then
	            cut = b - dy_top
	        elseif dy_bot < b then
	            cut = b - dy_bot
	        end
	
	        rectfill(x1 + cut, yy, x2 - cut, yy, col)
	    end
	end
	
	function bnrect(x, y, w, h, b, col)
	    if not b or b <= 0 then
	        rect(x, y, x + w, y + h, col)
	        return
	    end
	
	    local x1, y1 = x, y
	    local x2, y2 = x + w, y + h
	
	    local maxb = flr(min(w, h) / 2)
	    if b > maxb then b = maxb end
	
	    -- top/bottom straight edges (between chamfers)
	    line(x1 + b, y1, x2 - b, y1, col)
	    line(x1 + b, y2, x2 - b, y2, col)
	
	    -- left/right straight edges (between chamfers)
	    line(x1, y1 + b, x1, y2 - b, col)
	    line(x2, y1 + b, x2, y2 - b, col)
	
	    -- four chamfer diagonals
	    line(x1 + b, y1, x1, y1 + b, col)
	    line(x2 - b, y1, x2, y1 + b, col)
	    line(x2, y2 - b, x2 - b, y2, col)
	    line(x1, y2 - b, x1 + b, y2, col)
	end
	
	-- handle immediate or delayed page toggling
	function trigger_close(e)
	    if not e.switch_on_close then return end
	
	    if e.autoclose_delay and e.autoclose_delay > 0 then
	        e._close_timer = e.autoclose_delay
	    else
	        toggle_strings(ap, e.switch_on_close)
	    end
	end


---


        function elem_world_xy(e)
  -- world position with parent resolution (no camera subtraction)
  if not e then return 0, 0 end

  -- honor the same positioning rules used by ui drawing
  local x, y = get_abs_pos(e)

  -- allow get_abs_pos to return a table
  if type(x) == "table" then
    local t = x
    x = t.x or t[1] or 0
    y = t.y or t[2] or 0
  end

  return x or 0, y or 0
end

-- world collision helper that respects radius/size fields used by ui elements
function elems_collide_world(a, b)
  if not a or not b then return false end

  local function rects_overlap(x1,y1,x2,y2, rx1,ry1,rx2,ry2)
    return not (x2 < rx1 or rx2 < x1 or y2 < ry1 or ry2 < y1)
  end

  local function circ_circ_overlap(x1,y1,r1, x2,y2,r2)
    local dx = x2 - x1
    local dy = y2 - y1
    local rr = r1 + r2
    return (dx*dx + dy*dy) <= rr*rr
  end

  local function circ_rect_overlap(cx,cy,r, x1,y1,x2,y2)
    local closest_x = mid(x1, cx, x2)
    local closest_y = mid(y1, cy, y2)
    return ((cx - closest_x)^2 + (cy - closest_y)^2) <= r*r
  end

  local function elem_shape_world(e)
    local x, y = elem_world_xy(e)

    local r = e.radius or e.r
    if r then
      return "circ", x, y, r
    end

    local w = (e.size and e.size.w) or e.w or 0
    local h = (e.size and e.size.h) or e.h or 0
    return "rect", x, y, x + w, y + h
  end

  local t1,a1,b1,c1,d1 = elem_shape_world(a)
  local t2,a2,b2,c2,d2 = elem_shape_world(b)

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
	------------------------------------------------------------
	-- get_abs_pos
	-- base local pos (e.pos) + optional move_offset + parent
	------------------------------------------------------------
	function get_abs_pos(e)
	    if not e then return 0, 0 end
	
	    local x = (e.pos and e.pos.x) or 0
	    local y = (e.pos and e.pos.y) or 0
	
	    -- move offset is applied AFTER arrange has set base pos
	    if e.move_offset then
	        x += e.move_offset.x or 0
	        y += e.move_offset.y or 0
	    end
	
	    -- parent chain
	    if e.parent then
	        local px, py = get_abs_pos(e.parent)
	        x += px
	        y += py
	    end
	
	
	    return x, y
	end
	
	
	
	
	
	function close_upstage_group(page, e)
	    if not e.upstage then return end
	    local grp = e.upstage
	    local arr = ui[page]
	    if not arr then return end
	
	    -- FULL independent loop (not dependent on u_element loop)
	    for el in all(arr) do
	        if el ~= e and el.upstage == grp then
	
	            -- reset state
	            el.down=false
	            el.state="idle"
	            el.pressed_on=false
	            el.once=false
	            el.held=false
	
	            -- dropdowns close their options
	            if el.type=="dropdown" then
	                el.open=false
	            end
	
	            -- toggles: reset to default
	            if el.toggle_state ~= nil then
	                el.toggle_state = el.toggle_default or false
	                if el.ref then
	                    el.ref[1]=el.toggle_state
	                end
	            end
	        end
	    end
	end
	
	
	-- bring element to front (topmost on its page)
	function bring_to_front(page, e)
	    if not ui or not ui[page] or not e then return end
	    if e.behind_all then return end  -- never move background to front
	
	    local list = ui[page]
	    for i = #list, 1, -1 do
	        if list[i] == e then
	            deli(list, i)
	            list[#list+1] = e
	            break
	        end
	    end
	end
	
	
	function apply_upstage_pages(e)
	    if not e.upstage then return end
	
	    -- remove pages
	    for p in all(e.upstage) do
	        del(ap, p)
	    end
	
	    -- reset ALL elements on same parent page EXCEPT this one
	    local arr = ui[e.page]
	    if arr then
	        for el in all(arr) do
	            if el ~= e then
	                reset_toggle_visuals(el)
	            end
	        end
	    end
	end
	
	
	
	function reset_toggle_visuals(el)
	    if el.toggle_state ~= nil then
	        -- restore to default toggle state
	        el.toggle_state = el.toggle_default
	
	        -- reflect into ref table
	        if el.ref then
	            el.ref[1] = el.toggle_state
	        end
	    end
	
	    -- UI state reset (prevents hover/pressed colors from sticking)
	    el.down = false
	    el.state = "idle"
	    el.pressed_on = false
	    el.once = false
	    el.held = false
	
	    -- dropdowns should close
	    if el.type == "dropdown" then
	        el.open = false
	    end
	end
	
	
	
	
	
	
	-- simple helpers
	
	---
	
	function tquad(coords,tex,dx,dy)
		local screen_max = get_display():height()-1
		local p0,spans = coords[#coords],{}
		local x0,y0,u0,v0=p0.x+dx,p0.y+dy,p0.u,p0.v
		for i=1,#coords do
			local p1 = coords[i]
			local x1,y1,u1,v1=p1.x+dx,p1.y+dy,p1.u,p1.v
			local _x1,_y1,_u1,_v1=x1,y1,u1,v1
			if(y0>y1) x0,y0,x1,y1,u0,v0,u1,v1=x1,y1,x0,y0,u1,v1,u0,v0
			local dy=y1-y0
			local dx,du,dv=(x1-x0)/dy,(u1-u0)/dy,(v1-v0)/dy
			if(y0<0) x0-=y0*dx u0-=y0*du v0-=y0*dv y0=0
			local cy0=ceil(y0)
			local sy=cy0-y0
			x0+=sy*dx
			u0+=sy*du
			v0+=sy*dv
			for y=cy0,min(ceil(y1)-1,screen_max) do
				local span=spans[y]
				if span then tline3d(tex,span.x,y,x0,y,span.u,span.v,u0,v0)
				else spans[y]={x=x0,u=u0,v=v0} end
				x0+=dx
				u0+=du
				v0+=dv
			end
			x0,y0,u0,v0=_x1,_y1,_u1,_v1
		end
	end
	-- global page animation state
	ui_page_state = ui_page_state or {}
	
	
	-- helper: is a string in a list?
	function str_in_list(list, s)
	    for i = 1, #list do
	        if list[i] == s then return true, i end
	    end
	    return false, nil
	end
	
	ui_page_state = ui_page_state or {}
	
	-- internal: add a page to the page-list (ap) if not present
	local function ui_add_page(list, page, layer)
	    local found = str_in_list(list, page)
	    if not found then
	        if layer then
	            add(list, page, layer)
	        else
	            list[#list + 1] = page
	        end
	    end
	end
	
	--auto_close helper:
	-- close any auto_close elements when some element is clicked
	function auto_close_others(clicked)
	    if not ui then return end
	    ui_page_state = ui_page_state or {}
	    local clicked_page = clicked and clicked.page
	
	    for page_name, list in pairs(ui) do
	        for e in all(list) do
	            if e.auto_close and e ~= clicked then
	                local allow = false
	
	                if e.auto_close_whitelist then
	                    for _,p in ipairs(e.auto_close_whitelist) do
	                        if p == clicked_page then
	                            allow = true
	                            break
	                        
									 end
	                    end
	                end
	
	                if not allow then
	                    local p = e.page
	                    if ui_page_state[p] ~= "closing"
	                    and ui_page_state[p] ~= "closed" then
	                        ui_page_state[p] = "closing"
	                    end
	                end
	            end
	        end
	    end
	end
	
	-- shallow clone (with table copy for 1 level)
	function clone(t)
	    local out = {}
	    for k,v in pairs(t) do
	        if type(v) == "table" then
	            local nt = {}
	            for k2,v2 in pairs(v) do
	                nt[k2] = v2
	            end
	            out[k] = nt
	        else
	            out[k] = v
	        end
	    end
	    return out
	end
	
	------------------------------------------------------------
	-- clone_element(id, overrides)
	-- clones an existing element (found via ui_ids[id])
	-- and applies overrides, returning a NEW element instance
	------------------------------------------------------------
	function clone_element(src_id, overrides)
	    local src = ui_ids[src_id]
	    if not src then
	        click_msg="clone_element: no element found with id "..tostr(src_id)
	ct=ctd
	        return nil
	    end
	
	    -- shallow clone 1-level deep (tables copied, not shared)
	    local function shallow_clone(t)
	        local out = {}
	        for k,v in pairs(t) do
	            if type(v) == "table" then
	                local subt = {}
	                for k2,v2 in pairs(v) do
	                    subt[k2] = v2
	                end
	                out[k] = subt
	            else
	                out[k] = v
	            end
	        end
	        return out
	    end
	
	    -- 1. make a copy of the element table
	    local new = shallow_clone(src)
	
	    -- 2. apply overrides (including nested tables)
	    if overrides then
	        for k,v in pairs(overrides) do
	            if type(v) == "table" and type(new[k]) == "table" then
	                for k2,v2 in pairs(v) do
	                    new[k][k2] = v2
	                end
	            else
	                new[k] = v
	            end
	        end
	    end
	
	    -- 3. force it to be treated as a NEW element (fresh runtime state)
	    new.id              = overrides and overrides.id or nil
		 new.template			= false
	    new.down            = false
	    new.hover_t         = 0
	    new.pressed_on      = false
	    new.dragging        = false
	    new.r_pressed_on    = false
	    new.scroll_dragging = false
	    new.held            = false
	    new.once            = false
	
	    new._close_timer    = nil
	    new._arranged_once  = nil
	    new._last_page_state= nil
	
	    -- slide / wipe state reset so it starts like a new element
	    if new.wipe then
	        new.wipe.t    = 1
	        new.wipe.mode = "open"
	    end
	    if new.slide then
	        new.slide_t    = 1
	        new.slide_mode = "open"
	    end
	
	    -- 4. insert into UI directly (no i_element re-init)
	    local page = new.page or src.page
	    if not ui[page] then ui[page] = {} end
	
	    local list = ui[page]
	    list[#list+1] = new
	
	    if new.id then
	        ui_ids[new.id] = new
	    end
	
	    -- optional: run its i_func once on creation
	    if new.i_func then
	--        new:i_func()
	    end
	
	    return new
	end



----


	
	function page_is_active(page)
	    if not ap then return false end
	    for i=1,#ap do
	        if ap[i] == page then
	            return true
	        end
	    end
	    return false
	end
	
	
	-- global: which element is currently being dragged (if any)
	ui_drag_elem = ui_drag_elem or nil
	
	function drop_on_slot(page, e, mx, my)
	    local slot_hit = nil
	
	    if ui[page] then
	        -- find the first slot under the mouse
	        for i = 1, #ui[page] do
	            local s = ui[page][i]
	            if s.type == "slot" and s.visible ~= false then
	                local sx, sy = get_abs_pos(s)
	                local sw, sh = s.size.w, s.size.h
	                if mx >= sx and mx <= sx + sw
	                and my >= sy and my <= sy + sh then
	                    slot_hit = s
	                    break
	                end
	            end
	        end
	    end
	
	    -- free old slot if we had one
	    if e.slot and e.slot ~= slot_hit then
	        e.slot.held = false
	    end
	
	    if slot_hit then
	        -- snap element into slot (centered)
	        local sx, sy = get_abs_pos(slot_hit)
	        e.pos.x = sx + (slot_hit.size.w - e.size.w/2) 
	        e.pos.y = sy + (slot_hit.size.h - e.size.h/2) 
	
	        e.slot = slot_hit
	        slot_hit.held = true
	        e.held_in_slot = true
	    else
	        -- no slot: drop fails, snap back to origin
	        if e.slot then
	            e.slot.held = false
	            e.slot = nil
	        end
	        if e.drag_origin then
	            e.pos.x = e.drag_origin.x
	            e.pos.y = e.drag_origin.y
	        end
	        e.held_in_slot = false
	    end
	end

	
