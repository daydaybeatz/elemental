	
	--   LIBRARY INFO:
	--   pages must be in the ap={} (active pages) to be shown
	--   toggle_strings("page_str","str_id")
	
	--   ELEMENT ARGS:
	--   page="string" (which page to add the element to)
	--   type="container" (container, r_button, c_button, slider
	--                     dropdown, radio, spr_r_button, spr_c_button, spr_container)


	-- i_element (WITH TEMPLATE SUPPORT)
	-- templates:
	--   - set template=true OR page=="none"
	--   - templates do NOT get pushed into ui[page]
	--   - templates do NOT auto-run i_func
	--   - templates DO register ui_ids[id] so clone_element can find them



	
	--   label="string" (displays at self.x, self.y)
	
	--   label_col=7
	
	--   pos={x=0,y=0} (pos is: screen-relative if no parent, 
	--                  parent-relative if parent exists)
	
	--   tooltip={"str",delay,w,h,text_col,bg_col,out_col}  (shown on hover)
	
	--   size={w=50,h=50} (size of rect for containers and r_buttons)
	
	--   r=8 (radius for c_buttons)
	--   rrect=8 (draws rects as round rect with r as the radius of the bullnose)
	
	--   col={1,1,2,2,3,3}
	--       idle, hover, and clicked col and outline groups
	
	--   sprites={1,2,3,4}
	--       idle, hover, toggled, toggled-hover
	
	--   parent="str_id" (makes element draw at parents position
	
	--   offset = {x=0,y=0} (label draw offset)
	--   id="string" (for parenting/auto-arrange behavior)
	
	--   data={health=100, money=100} (used to hold data per element)
	--   hover_animation = {"circle"/"shake"/"bounce", amt, speed}
	
	--   open/closing animations
	--   wipe = {"left"/"right"/"up"/"down", speed} (.009-.07)
	--   slide = {x1,y1,x2,y2,speed} -- speed is very small, .01-.1
	
	--   call this to have an element start in its closed 'slide' position:
	--   init_slide_closed("stats_bg")
	
	--   swaps={}
	
	--   visible=true/false (visually and physically hides the element)
	
	--   arrange={"str_id",x_padding,y_padding}
	
	
	--   slot=true (makes an element able to hold another element)
	--   draggable=true (allows click-dragging of an element)
	
	--   i_func=function()  end, a function that will run on creation of element
	--   func=function()   end, a function that runs upon clicking an element
	--   r_func=function()   end, a function that runs upon right clicking an element
	--
	--   h_func = function(self) end
	
	--   called every frame the mouse is colliding/hovering with the element (uses the same rect/circ hit test you already use).
	
	--   c_func = function(self, collider_str_id) end
	
	--   called every frame the element is colliding with another element whose id is given by:
	--   args.collider_id, or
	--   args.collider, or
	--   args.collide_with (any of those names work).
	
	--create i_element with c_func arg:
	
	--    c_func = function(self, other_id)
	--        -- other is the collider element
	--        -- other_id is other.id (string)
	--
	--        if other.id == "mouse" then
	--            click_msg = "touched by fake mouse"
	--        elseif other_id == "mouse" then
	--            click_msg = "player hit stats bg"
	--        elseif other and other.tag == "bullet" then
	--            click_msg = "shot by bullet"
	--        end
	--
	--        ct = ctd
	--    end
	--   Supports rect vs rect, circ vs circ, and rect vs circ.
	
	
	--   a_update=()     end,  a function that runs even while element is not 'visible'
	--   update=function()   end, a function that runs WHILE the element is 'visible'
	--   draw=function(self,x,y)   end, a draw function for extra/custom drawing per element
	--
	--   hide=true/false, (hides the default draw code so you can use 
	--                     your own 'draw' function, you can still interact while hidden)
	
	--   type="slider"
	--    fw    = 60,      -- track width
	--    fh    = 3,       -- thumb radius
	--    max   = 1,       -- value range 0..1
	--    ref   = volume_ref, -- variable home
	
	--   options={"option1", "option2", "option3"} (labels for each value)
	--   default_option=str/int (starting value)
	--   values={"value","value","value"}  (str or int, actual value stored in ref)
	--   open=true/false (you can set a list to start open/closed)
	--   padding={x=0,y=0} (label padding between options)
	
	--	  dropdown=true (turns a radio list into a dropdown radio list)
	
	--  TIPS:
	--
	--  local px,py=get_abs_pos(self) within an elements func/draw 
	--   to draw at the elements 0,0
	
	-- other stuff i need to document:
	
	--   upstage={}
	--   focus=true/false?
	--   scroll={items,}
	--   multi_select=true/false (allows a radio list to select multiple values)
	
	--   autoclose=true/false
	--        autoclose_delay = 10
	--        autoclose_page  = "page",
	--        switch_on_close = {"page","page"}
	
	
	-- bugs:
	-- dropdown type seems to close all pages when an option is selected
	
	

-------
-------
-------
-------
--------------
	-- init all, update all, and draw all of the elements
	-----
	function init_elements()
	
	-- global mouse edge state
	mouse_mb_prev   = 0
	mouse_clicked   = false   -- left button pressed THIS frame (1-frame true)
	mouse_released  = false   -- left button released THIS frame
	mouse_r_clicked = false   -- right button pressed THIS frame
	mouse_r_released= false   -- right button released THIS frame
	
	mouse_x,mouse_y=mouse()
		-- click feedback
		click_msg = ""
		ctd = 90
		ct = 0
		log={}
		
		ap={}
		ui = {}
		ui_ids = {}
		click_msg =  ""
		msg_color = 7
		
		-- put this at top-level
		ui_active_item_id = nil
	
	
	--toggle_ref = {false}
	--slider_ref = {0.5}
	--difficulty = {2} -- starts on "Medium"
		selected_item = ""
	
	
	-- Allowed UI element types
		allowed_types = {
		    c_button  = true,
		    r_button  = true,
		    dropdown  = true,
		    slider    = true,
		    container = true,
		    spr_r_button  = true,  -- NEW
		    spr_c_button  = true,   -- NEW
			 radio=true,
			slot=true, -- <- IMPORTANT,
			spr_container  = true -- ????? new
	
		}
		
				particles        = particles        or {}
				emitters  = {}
				
	
	
	end
	
	
	function update_elements()
	--u_camera_lock()
	u_sfx_gate()
	mouse_x,mouse_y=mouse()
	u_world_clamp("player1", 32, 32, 16, 16, 0, 0)
	
	u_camera_edge_lock(32,32,16,16, 480,270)
	u_camera_follow_player()
		update_mouse_edge()
		
		
		--main element updating
		foreach(ap,u_element)
		
		--particles are updated here
		u_particle()
		
		
		-- click message timer
	   if ct and ct > 0 then
			ct -= 1
	   end
	
	    if ui_shake_t and ui_shake_t > 0 then
	        ui_shake_t -= 1
	        if ui_shake_t <= 0 then
	            ui_shake_t   = 0
	            ui_shake_amt = 0
	        end
	    end
	end
	
	
function draw_elements()
  local sx, sy = 0, 0
  if ui_shake_t and ui_shake_t > 0 then
    sx = flr(rnd(ui_shake_amt * 2 + 1)) - ui_shake_amt
    sy = flr(rnd(ui_shake_amt * 2 + 1)) - ui_shake_amt
  end

  camera(sx, sy)

  foreach(ap, d_element)

  -- draw particles here (uses ps.space + cam internally)
  d_particle()

  camera(0, 0)

  if ct and ct > 0 and click_msg and #click_msg > 0 then
    print(click_msg, 4, 260, msg_color)
  end
end
	
	-------
	
	

	
	
	
	
	
	------------------------------------------------------------
-- i_element:
	------------------------------------------------------------
	function i_element(arg1, arg2, arg3, arg4)
	  local args = arg1
	  if type(arg1) ~= "table" then
	    args       = arg4 or {}
	    args.page  = arg1
	    args.type  = arg2
	    args.label = arg3
	  end
	
	  ui    = ui    or {}
	  ui_ids= ui_ids or {}
	
	  local page  = args.page
	  local etype = args.type or "r_button"
	
	  if not allowed_types[etype] then
	    printh("Invalid element type: "..tostr(etype))
	    return
	  end
	
	  --------------------------------------------------------
	  -- TEMPLATE RULE
	  --------------------------------------------------------
	  local is_template = (args.template == true)
	
	  if not ui[page] then ui[page] = {} end
	
	  --------------------------------------------------------
	  -- resolve parent: string id or direct ref
	  --------------------------------------------------------
	  local parent_ref = args.parent
	  if type(parent_ref) == "string" and ui_ids then
	    parent_ref = ui_ids[parent_ref]
	  end
	
	  local e = {
	    page    = page,
	    type    = etype,
	    label   = args.label or "",
	    label_col = args.label_col or 7,
	
	    id      = args.id,
	
	    -- world/ui space flags (optional)
	    world   = (args.world == true) or (args.space == "world"),
	    space   = args.space, -- "world" or "ui" (optional)
	
	    -- parent relationship (used by get_abs_pos)
	    parent  = parent_ref,
	
	    data    = args.data or {},
	
	    pos     = args.pos    or {x = 0, y = 0},
	    offset  = args.offset or {x = 0, y = 0},
	    draw_offset    = args.draw_offset    or {x = 0, y = 0},
	    element_offset = args.element_offset or {x = 0, y = 0},
	
	    size    = args.size   or {w = 40, h = 14},
	    r       = args.r,
	    rrect   = args.rrect,
	    bullnose= args.bullnose,
	
	    col     = args.colors or {1, 2, 1, 7, 3, 7},
	    sprites = args.sprites,
	
	    i_func  = args.i_func,
	    func    = args.func,
	    r_func  = args.r_func,
	    ref     = args.ref,
	
	    -- hover + collision callbacks
	    h_func      = args.h_func,
	    c_func      = args.c_func,
	    collider_id = args.collider_id or args.collider or args.collide_with,
	
	    max     = args.max or 1,
	    fw      = args.fw or 40,
	    fh      = args.fh or 6,
	
	    visible = args.visible ~= false,
	    down    = false,
	    once    = false,
	    held    = false,
	
	    a_update  = args.a_update,
	    update  = args.update,
	    draw    = args.draw,
	
	    -- dropdown / radio
	    options  = args.options,
	    values   = args.values,
	    selected = args.selected,
	    open     = (args.open ~= false),
	
	    default_option   = args.default_option,
	    tooltip          = args.tooltip,
	    display_selected = args.display_selected == true,
	
	    dropdown = args.dropdown == true,
	    padding  = args.padding or {x = 4, y = 8},
	
	    autoclose_delay = args.autoclose_delay,
	    autoclose_page  = args.autoclose_page,
	    _close_timer    = nil,
	    switch_on_close = args.switch_on_close or args.autoclose_page,
	
	    focus  = args.focus == true,
	    upstage= args.upstage,
	
	    hide = args.hide or false,
	
	    -- arrange layout only; does NOT touch parent
	    -- arrange = {parent_id, pad_x, pad_y, opt_row, opt_col}
	    arrange = args.arrange,
	
	    -- follow = { target_id, speed, [offset_x], [offset_y] }
	    follow  = nil,
	
	    multi_select = args.multi_select == true,
	    selected_set = args.selected_set,
	
	    -- drag / slot
	    draggable = args.draggable == true,
	    slot      = nil,
	    dragging  = false,
	    drag_start_mx = nil,
	    drag_start_my = nil,
	    drag_last_mx  = nil,
	    drag_last_my  = nil,
	    drag_origin   = nil,
	    held_in_slot  = false,
	
	    -- move: layout move, independent of slot-dragging
	    move          = args.move == true,
	    moving        = false,
	    move_start_mx = nil,
	    move_start_my = nil,
	    move_last_mx  = nil,
	    move_last_my  = nil,
	    move_offset   = {x = 0, y = 0},
	
	    -- confirm system
	    confirm     = args.confirm == true,
	    confirm_msg = args.confirm_msg,
	
	    _last_page_state = nil,
	
	    behind_all = args.behind_all == true,
	
	    -- mark template
	    template = is_template
	  }
	
	  --------------------------------------------------------
	  -- helper: resolve value from index (radio/dropdown)
	  --------------------------------------------------------
	  local function resolve_value_from_index(idx)
	    if not idx then return nil end
	    local v = nil
	    if e.values then
	      if e.values[idx] ~= nil then
	        v = e.values[idx]
	      elseif e.options and e.values[e.options[idx]] ~= nil then
	        v = e.values[e.options[idx]]
	      end
	    end
	    if v == nil and e.options then
	      v = e.options[idx]
	    end
	    return v
	  end
	
	  --------------------------------------------------------
	  -- radio defaults
	  --------------------------------------------------------
	  if e.type == "radio" then
	    if not e.multi_select then
	      if e.selected == nil then
	        if args.default_option ~= nil then
	          e.default_option = args.default_option
	          e.selected       = args.default_option
	        elseif args.selected ~= nil then
	          e.selected = args.selected
	        end
	      end
	
	      if e.selected and e.ref then
	        local v = resolve_value_from_index(e.selected)
	        e.ref[1] = v
	      end
	    end
	
	  --------------------------------------------------------
	  -- dropdown defaults
	  --------------------------------------------------------
	  elseif e.type == "dropdown" then
	    if e.selected == nil then
	      if args.default_option ~= nil then
	        e.default_option = args.default_option
	        e.selected       = args.default_option
	      elseif args.selected ~= nil then
	        e.selected = args.selected
	      end
	    end
	
	    if e.selected and e.ref then
	      local v = resolve_value_from_index(e.selected)
	      e.ref[1] = v
	    end
	  end
	
	  --------------------------------------------------------
	  -- hover animation
	  --------------------------------------------------------
	  if args.hover_animation then
	    local ha = args.hover_animation
	    e.hover_anim_type  = ha[1]
	    e.hover_anim_amt   = ha[2] or 2
	    e.hover_anim_speed = ha[3] or 0.08
	
	    e.hover_anim_t   = 0
	    e.hover_offset_x = 0
	    e.hover_offset_y = 0
	    e.pulse_scale    = 1
	  end
	
	  --------------------------------------------------------
	  -- element animation (always-on)
	  -- animation = {"circle"/"shake"/"bounce", amt, speed}
	  --------------------------------------------------------
	  if args.animation then
	    local an = args.animation
	    e.anim_type  = an[1]
	    e.anim_amt   = an[2] or 2
	    e.anim_speed = an[3] or 0.08
	    e.anim_t     = 0
	    e.anim_offset_x = 0
	    e.anim_offset_y = 0
	    e.anim_on = true
	  end
	
	  --------------------------------------------------------
	  -- scroll
	  --------------------------------------------------------
	  if args.scroll ~= nil then
	    local s  = args.scroll
	    local n, hw, hc, hco
	    if type(s) == "table" then
	      n   = s[1]
	      hw  = s[2]
	      hc  = s[3]
	      hco = s[4]
	    else
	      n = s
	    end
	
	    if type(n) == "number" and n > 0 then
	      e.scroll_items      = n
	      e.scroll_offset     = 0
	      e.scroll_handle_w   = hw or 4
	      e.scroll_handle_col = hc or 6
	      e.scroll_handle_out = hco or 0
	    end
	  end
	
	  --------------------------------------------------------
	  -- toggle
	  --------------------------------------------------------
	  if args.toggle then
	    local t = args.toggle
	    e.toggle_default = t[1] and true or false
	    e.toggle_state   = e.toggle_default
	
	    e.toggle_off_fill = t[2]
	    e.toggle_off_out  = t[3]
	    e.toggle_on_fill  = t[4] or t[2]
	    e.toggle_on_out   = t[5] or t[3]
	
	    if e.ref then e.ref[1] = e.toggle_state end
	  end
	
	  --------------------------------------------------------
	  -- wipe (element/page animation clip)
	  -- wipe = {dir, speed}
	  --------------------------------------------------------
	  if args.wipe then
	    e.wipe = {
	      dir   = args.wipe[1] or "left",
	      speed = args.wipe[2] or 0.2,
	      t     = 1,
	      mode  = "open"
	    }
	  end
	
	  --------------------------------------------------------
	  -- slide
	  -- slide = {x1, y1, x2, y2, speed}
	  --------------------------------------------------------
	  if args.slide then
	    local s = args.slide
	
	    e.slide = { s[1], s[2], s[3] or s[1], s[4] or s[2] }
	
	    e.slide_cfg   = {e.slide[1], e.slide[2], e.slide[3], e.slide[4]}
	    e.slide_speed = s[5] or 0.1
	    e.slide_t     = 0
	    e.slide_mode  = "closed"
	  end
	
	  --------------------------------------------------------
	  -- follow = { target_id, speed, [offset_x], [offset_y] }
	  --------------------------------------------------------
	  if args.follow then
	    local f = args.follow
	    e.follow = {
	      target_id = f[1],
	      speed     = f[2] or 0.1,
	      ox        = f[3],
	      oy        = f[4],
	      init      = false
	    }
	  end
	
	  --------------------------------------------------------
	  -- auto_close
	  --------------------------------------------------------
	  if args.auto_close ~= nil or args.auto_close_whitelist ~= nil then
	    if type(args.auto_close) == "table" then
	      e.auto_close = args.auto_close[1] and true or false
	      if #args.auto_close > 1 then
	        e.auto_close_whitelist = {}
	        local wl = e.auto_close_whitelist
	        for i = 2, #args.auto_close do
	          local p = args.auto_close[i]
	          if type(p) == "string" then
	            wl[#wl+1] = p
	          end
	        end
	      end
	    else
	      e.auto_close = (args.auto_close == nil) and true or (args.auto_close == true)
	    end
	
	    if args.auto_close_whitelist then
	      e.auto_close_whitelist = e.auto_close_whitelist or {}
	      local wl = e.auto_close_whitelist
	      for _,p in ipairs(args.auto_close_whitelist) do
	        if type(p) == "string" then
	          wl[#wl+1] = p
	        end
	      end
	    end
	  end
	
	
	
	  --------------------------------------------------------
	  -- register id
	  --------------------------------------------------------
	  if e.id then
	    ui_ids[e.id] = e
	  end
	
	  --------------------------------------------------------
	  -- TEMPLATE EXIT (no ui insertion, no auto i_func)
	  --------------------------------------------------------
	  if is_template then
	    e.visible = false
	    return e
	  end
	
	  --------------------------------------------------------
	  -- push into page list (front-most by default)
	  --------------------------------------------------------
	  local list = ui[page]
	
	  if e.behind_all then
	    for i = #list, 1, -1 do
	      list[i+1] = list[i]
	    end
	    list[1] = e
	  else
	    list[#list+1] = e
	    if bring_to_front then
	      bring_to_front(page, e)
	    end
	  end
	
	  --------------------------------------------------------
	  -- run i_func immediately if page is active
	  --------------------------------------------------------
	  if e.i_func and page_is_active and page_is_active(page) then
	    e._i_func_ran = true
	    e:i_func()
	  end
	
	  return e
	end
	
	
	
	
	
	
	
	
	-------
	--------
	-------
	
	
	
	
	
	
	------------------------------------------------------------
	-- u_element (page + element-level animations, click-once)
	-- NOTE: camera/world-space support
	--  - assumes get_abs_pos(e) returns WORLD abs position (parent-resolved)
	--  - elements with e.world=true (or e.space=="world") are drawn/hit-tested in SCREEN
	--    by subtracting cam.x/cam.y
	--  - UI elements (default) ignore cam
	------------------------------------------------------------
	-- u_element (page + element-level animations, click-once)
	-- NOTE: camera/world-space support
	--  - assumes get_abs_pos(e) returns WORLD abs position (parent-resolved)
	--  - elements with e.world=true (or e.space=="world") are drawn/hit-tested in SCREEN
	--    by subtracting cam.x/cam.y
	--  - UI elements (default) ignore cam
	------------------------------------------------------------
	function u_element(page)
	  local mx, my, mb, wh, wv = mouse()
	
	  ui_elem_state = ui_elem_state or {}
	
	  cam = cam or {x=0,y=0}
	
	  --------------------------------------------------------
	  -- camera helpers
	  --------------------------------------------------------
	
	
	
	  local function is_world(e)
	    return (e and (e.world == true or e.space == "world"))
	  end
	
	  local function elem_world_xy(e)
	    return get_abs_pos(e) -- treat as world abs (parent-resolved)
	  end
	
	  local function elem_screen_xy(e)
	    local x, y = elem_world_xy(e)
	    if is_world(e) then
	      x -= cam.x or 0
	      y -= cam.y or 0
	    end
	    return x, y
	  end
	
	  --------------------------------------------------------
	  -- small collision helpers (rect/circ) (SCREEN-SPACE)
	  --------------------------------------------------------
	  local function point_in_rect(px, py, x1, y1, x2, y2)
	    return px >= x1 and px <= x2 and py >= y1 and py <= y2
	  end
	
	  local function point_in_circ(px, py, cx, cy, r)
	    return ((px - cx)^2 + (py - cy)^2) <= (r * r)
	  end
	
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
	
	  local function elem_shape_screen(e)
	    local x, y = elem_screen_xy(e)
	    if e.type == "c_button" or e.type == "spr_c_button" then
	      local r = e.r or 8
	      return "circ", x, y, r
	    else
	      local w, h = e.size.w, e.size.h
	      return "rect", x, y, x + w, y + h
	    end
	  end
	
	  local function elem_center_screen(e)
	    local t,a,b,c,d = elem_shape_screen(e)
	    if t == "circ" then
	      return a, b
	    else
	      return (a + c) * 0.5, (b + d) * 0.5
	    end
	  end
	
	  local function elems_collide_screen(e1, e2)
	    if not e1 or not e2 then return false end
	
	    local t1,a1,b1,c1,d1 = elem_shape_screen(e1)
	    local t2,a2,b2,c2,d2 = elem_shape_screen(e2)
	
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
	-- add this helper near your other helpers inside u_element (same scope as elem_screen_xy)
	-- replace your elem_draw_screen_xy helper with this version
	local function elem_draw_screen_xy(e)
	  local x, y = elem_screen_xy(e)
	
	  -- match d_element visual offsets so particles line up with spr()
	  if e.hover_anim_type then
	    x += e.hover_offset_x or 0
	    y += e.hover_offset_y or 0
	  end
	
	  if e.anim_type then
	    x += e.anim_offset_x or 0
	    y += e.anim_offset_y or 0
	  end
	
	  if e.element_offset then
	    x += e.element_offset.x or 0
	    y += e.element_offset.y or 0
	  end
	
	  return x, y
	end
	
	
	  --------------------------------------------------------
	  -- per-page mouse edge detection
	  --------------------------------------------------------
	  ui_page_mouse_prev_mb = ui_page_mouse_prev_mb or {}
	  local prev_mb = ui_page_mouse_prev_mb[page] or 0
	
	  local mouse_pressed  = (mb == 1 and prev_mb ~= 1)
	  local mouse_released = (mb ~= 1 and prev_mb == 1)
	  local r_pressed      = (mb == 2 and prev_mb ~= 2)
	  local r_released     = (mb ~= 2 and prev_mb == 2)
	
	  ui_page_mouse_prev_mb[page] = mb
	
	  if not ui[page] then ui[page] = {} end
	
	  ui_page_state      = ui_page_state      or {}
	  ui_page_prev_state = ui_page_prev_state or {}
	
	  if not ui_page_state[page] then
	    ui_page_state[page] = "open"
	  end
	
	  local page_state = ui_page_state[page]
	  local opening    = (page_state == "opening")
	  local closing    = (page_state == "closing")
	
	  local prev_state  = ui_page_prev_state[page] or "closed"
	  local just_opened = (prev_state == "closed"
	                    and (page_state == "open" or page_state == "opening"))
	
	  if just_opened and ui[page] then
	    for e in all(ui[page]) do
	      if e.type == "dropdown" then
	        e.open          = true
	        e.scroll_offset = e.scroll_offset or 0
	      end
	
	      if e.i_func and not e._i_func_ran then
	        e:i_func()
	        e._i_func_ran = true
	      end
	    end
	  end
	
	  local page_has_anim       = false
	  local page_all_open_done  = true
	  local page_all_close_done = true
	
	  local drag_threshold = 4
	
	  --------------------------------------------------------
	  -- MAIN ELEMENT UPDATE LOOP
	  --------------------------------------------------------
	  for i = #ui[page], 1, -1 do
	    local e = ui[page][i]
	
	    if e and e.a_update then
	      e:a_update()
	    end
	
	    if not e or e.visible == false then goto skip end
	
	    ----------------------------------------------------
	    -- ensure pos exists early (for drag/move/follow)
	    ----------------------------------------------------
	    if not e.pos then
	      e.pos = {x = 0, y = 0}
	    else
	      if e.pos.x == nil then e.pos.x = 0 end
	      if e.pos.y == nil then e.pos.y = 0 end
	    end
	
	    if e.arrange then auto_arrange(e) end
	
	    ----------------------------------------------------
	    -- FOLLOW: element tracks another element with delay
	    -- uses WORLD coords (camera ignored)
	    ----------------------------------------------------
	    if e.follow and ui_ids then
	      local f = e.follow
	      local target = ui_ids[f.target_id]
	      if target and target.visible ~= false then
	        local tx, ty = elem_world_xy(target)
	
	        local px, py = 0, 0
	        if e.parent then
	          px, py = elem_world_xy(e.parent)
	        end
	
	        if not f.init then
	          if f.ox == nil or f.oy == nil then
	            local ex, ey = elem_world_xy(e)
	            f.ox = ex - tx
	            f.oy = ey - ty
	          end
	          f.init = true
	        end
	
	        local speed  = f.speed or 0.1
	        local goal_x = tx + (f.ox or 0) - px
	        local goal_y = ty + (f.oy or 0) - py
	
	        e.pos.x += (goal_x - e.pos.x) * speed
	        e.pos.y += (goal_y - e.pos.y) * speed
	      end
	    end
	
	    ----------------------------------------------------
	    -- SCREEN coords for hit tests
	    ----------------------------------------------------
	    local x, y = elem_screen_xy(e)
	    local hovered = false
	
	    if e.type == "c_button" or e.type == "spr_c_button" then
	      hovered = ((mx - x)^2 + (my - y)^2) < ((e.r or 8)^2)
	    elseif e.type == "slider" then
	      hovered = mx >= x - e.fw/2 and mx <= x + e.fw/2
	             and my >= y - e.fh/2 and my <= y + e.fh/2
	    else
	      local w, h = e.size.w, e.size.h
	      hovered = mx >= x and mx <= x + w and my >= y and my <= y + h
	    end
	
	    if hovered then
	      e.hover_t = (e.hover_t or 0) + 1
	    else
	      e.hover_t = 0
	    end
	
	    ----------------------------------------------------
	    -- HOVER ANIMATION UPDATE (incl pulse)
	    ----------------------------------------------------
	    if e.hover_anim_type then
	      local t   = e.hover_anim_t   or 0
	      local amt = e.hover_anim_amt or 2
	      local spd = e.hover_anim_speed or 0.08
	
	      if hovered then
	        t += spd
	
	        if e.hover_anim_type == "pulse" then
	          local s = 1 + sin(t) * amt
	          e.pulse_scale    = s
	          e.hover_offset_x = 0
	          e.hover_offset_y = 0
	        else
	          local hx, hy = 0, 0
	
	          if e.hover_anim_type == "circle" then
	            hx = cos(t) * amt
	            hy = sin(t) * amt
	          elseif e.hover_anim_type == "shake" then
	            hx = sin(t*4) * amt
	            hy = 0
	          elseif e.hover_anim_type == "bounce" then
	            hy = -abs(sin(t)) * amt
	            hx = 0
	          end
	
	          e.hover_offset_x = hx
	          e.hover_offset_y = hy
	        end
	      else
	        if e.hover_anim_type == "pulse" then
	          e.pulse_scale = 1
	        else
	          e.hover_offset_x = 0
	          e.hover_offset_y = 0
	        end
	      end
	
	      e.hover_anim_t = t
	    end
	
	    e.pressed_on      = e.pressed_on      or false
	    e._close_timer    = e._close_timer    or nil
	    e.once            = e.once            or false
	    e.r_pressed_on    = e.r_pressed_on    or false
	    e.scroll_dragging = e.scroll_dragging or false
	
	
	    ----------------------------------------------------
	    -- ELEMENT ANIMATION UPDATE (always-on)
	    ----------------------------------------------------
	    if e.anim_type and e.anim_on ~= false then
	      local t   = (e.anim_t or 0) + (e.anim_speed or 0.08)
	      local amt = e.anim_amt or 2
	      local ax, ay = 0, 0
	
	      if e.anim_type == "circle" then
	        ax = cos(t) * amt
	        ay = sin(t) * amt
	
	      elseif e.anim_type == "shake" then
	        -- deterministic ???shake??? (no rnd jitter)
	        ax = sin(t*6) * amt
	        ay = cos(t*7) * amt * 0.5
	
	      elseif e.anim_type == "bounce" then
	        ax = 0
	        ay = -abs(sin(t)) * amt
	      end
	
	      e.anim_offset_x = ax
	      e.anim_offset_y = ay
	      e.anim_t = t
	    end
	
	
	    local in_slot = (e.slot ~= nil)
	
	    ----------------------------------------------------
	    -- h_func (hover)
	    ----------------------------------------------------
	    if e.h_func and hovered then
	      e:h_func()
	    end
	
	    ----------------------------------------------------
	    -- while dragging SOME element, all *other* elements ignore mouse logic
	    ----------------------------------------------------
	    local skip_mouse = (ui_drag_elem and ui_drag_elem ~= e)
	    if skip_mouse then
	      goto after_mouse
	    end
	
	    ----------------------------------------------------
	    -- SCROLL WHEEL (dropdown & radio)
	    ----------------------------------------------------
	    if e.scroll_items and e.options and (wv ~= 0)
	    and (e.type == "dropdown" or e.type == "radio") then
	
	      local pad_y
	      local line_h
	      local top_y
	      local total_visible_h
	
	      if e.type == "dropdown" then
	        pad_y  = (e.padding and e.padding.y) or e.size.h
	        line_h = pad_y
	        top_y  = y + e.size.h
	      else
	        pad_y  = (e.padding and e.padding.y) or 8
	        line_h = pad_y
	        if e.dropdown then
	          top_y = y + e.size.h
	        else
	          top_y = y
	        end
	      end
	
	      total_visible_h = (e.scroll_items or #e.options) * line_h
	
	      local in_scroll_area =
	        mx >= x and mx <= x + e.size.w and
	        my >= top_y and my <= top_y + total_visible_h
	
	      if in_scroll_area then
	        local offset = e.scroll_offset or 0
	        local max_offset = max(0, #e.options - (e.scroll_items or #e.options))
	
	        if wv > 0 then offset -= 1
	        elseif wv < 0 then offset += 1 end
	
	        if offset < 0 then offset = 0 end
	        if offset > max_offset then offset = max_offset end
	
	        e.scroll_offset = offset
	      end
	    end
	
	    ----------------------------------------------------
	    -- SCROLL HANDLE DRAG (dropdown & radio)
	    ----------------------------------------------------
	    if e.scroll_items and e.options
	    and (e.type == "dropdown" or e.type == "radio") then
	
	      local total = #e.options
	      local visible_n = e.scroll_items or total
	
	      if total > visible_n then
	        local pad_y
	        local line_h
	        local start_y
	
	        if e.type == "dropdown" then
	          if e.open then
	            pad_y  = (e.padding and e.padding.y) or e.size.h
	            line_h = pad_y
	            start_y = y + e.size.h
	          end
	        else
	          pad_y  = (e.padding and e.padding.y) or 8
	          line_h = pad_y
	          if e.dropdown then
	            if e.open then start_y = y + e.size.h end
	          else
	            start_y = y
	          end
	        end
	
	        if start_y then
	          local visible = min(total, visible_n)
	          local list_top    = start_y
	          local list_bottom = start_y + visible * line_h
	
	          local track_w = e.scroll_handle_w or 4
	          local track_x1 = x + e.size.w - track_w
	          local track_x2 = x + e.size.w
	          local track_y1 = list_top
	          local track_y2 = list_bottom
	          local track_h  = track_y2 - track_y1
	
	          local max_offset = max(1, total - visible_n)
	          local handle_h = max(4, flr(track_h * visible_n / total))
	          local ratio = (e.scroll_offset or 0) / max_offset
	          if ratio < 0 then ratio = 0 end
	          if ratio > 1 then ratio = 1 end
	
	          local handle_y1 = track_y1 + flr((track_h - handle_h) * ratio)
	          local handle_y2 = handle_y1 + handle_h
	
	          if mb == 1 then
	            if not e.scroll_dragging then
	              if mx >= track_x1 and mx <= track_x2
	              and my >= handle_y1 and my <= handle_y2 then
	                e.scroll_dragging = true
	                e.scroll_drag_offset = my - handle_y1
	              end
	            end
	
	            if e.scroll_dragging then
	              local new_handle_y1 = my - (e.scroll_drag_offset or 0)
	              if new_handle_y1 < track_y1 then new_handle_y1 = track_y1 end
	              if new_handle_y1 > track_y1 + (track_h - handle_h) then
	                new_handle_y1 = track_y1 + (track_h - handle_h)
	              end
	
	              local new_ratio = 0
	              if track_h > handle_h then
	                new_ratio = (new_handle_y1 - track_y1) / (track_h - handle_h)
	              end
	              if new_ratio < 0 then new_ratio = 0 end
	              if new_ratio > 1 then new_ratio = 1 end
	
	              local new_offset = flr(new_ratio * max_offset + 0.5)
	              if new_offset < 0 then new_offset = 0 end
	              if new_offset > max_offset then new_offset = max_offset end
	
	              e.scroll_offset = new_offset
	              goto after_mouse
	            end
	          else
	            e.scroll_dragging = false
	          end
	        end
	      end
	    end
	
	    ----------------------------------------------------
	    -- RIGHT CLICK HANDLER (r_func) for non-radio
	    ----------------------------------------------------
	    if e.type ~= "radio" then
	      if r_pressed then
	        if hovered and not e.r_pressed_on then
	          e.r_pressed_on = true
	          if e.r_func then e.r_func(e) end
	          return
	        end
	      elseif r_released then
	        e.r_pressed_on = false
	      end
	    end
	
	    ----------------------------------------------------
	    -- SLIDER
	    ----------------------------------------------------
	    if e.type == "slider" then
	      if mb == 1 and (hovered or e.held) then
	        if not e.held and mouse_pressed then
	          auto_close_others(e)
	          if e.focus then bring_to_front(page, e) end
	        end
	        e.held = true
	        local dx  = ((mx - x)/e.fw) + 0.5
	        local val = clamp(dx * e.max, 0, e.max)
	        e.value = val
	        if e.ref then e.ref[1] = val end
	        if e.update then e:update() end
	        return
	      elseif mouse_released then
	        e.held = false
	      end
	      if e.ref then e.value = e.ref[1] end
	    end
	
	    ----------------------------------------------------
	    -- DROPDOWN (supports per-option functions in values)
	    ----------------------------------------------------
	    if e.type == "dropdown" then
	      if hovered and mouse_pressed and not e.once then
	        e.once = true
	        auto_close_others(e)
	        if e.focus then bring_to_front(page, e) end
	        apply_upstage_pages(e)
	        e.open = true
	        return
	      elseif mouse_released then
	        e.once = false
	      end
	
	      if not e.scroll_dragging and e.open and e.options and #e.options > 0 then
	        local pad_y  = (e.padding and e.padding.y) or e.size.h
	        local line_h = pad_y
	        local start_y= y + e.size.h
	        local offset = e.scroll_offset or 0
	        local visible = e.scroll_items or #e.options
	
	        for i_opt, label in ipairs(e.options) do
	          local row = i_opt - offset
	          if row >= 1 and row <= visible then
	            local oy = start_y + (row - 1) * line_h
	            if my >= oy and my <= oy + line_h
	            and mx >= x  and mx <= x + e.size.w then
	              if mouse_pressed then
	                auto_close_others(e)
	                if e.focus then bring_to_front(page, e) end
	                apply_upstage_pages(e)
	
	                e.selected = i_opt
	
	                local val = nil
	                if e.values then
	                  if e.values[i_opt] ~= nil then
	                    val = e.values[i_opt]
	                  elseif e.values[label] ~= nil then
	                    val = e.values[label]
	                  end
	                end
	
	                if type(val) == "function" then
	                  val(e, i_opt, label)
	                  if e.ref then e.ref[1] = label end
	                else
	                  local v = (val ~= nil) and val or label
	                  if e.ref then e.ref[1] = v end
	                  if e.func then e.func(e, i_opt, v) end
	                end
	
	                e.open = false
	                trigger_close(e)
	                toggle_string(ap, e.page)
	                return
	              end
	            end
	          end
	        end
	      end
	    end
	
	    ----------------------------------------------------
	    -- RADIO (including dropdown-style radio)
	    ----------------------------------------------------
	    if e.type == "radio" and e.options then
	      local pad_y  = (e.padding and e.padding.y) or 8
	      local line_h = pad_y
	      local opt_index = nil
	      local offset    = e.scroll_offset or 0
	      local visible   = e.scroll_items or #e.options
	
	      if e.dropdown then
	        if e.open then
	          local start_y = y + e.size.h
	          if mx >= x and mx <= x + e.size.w then
	            for i_opt,_ in ipairs(e.options) do
	              local row = i_opt - offset
	              if row >= 1 and row <= visible then
	                local oy = start_y + (row - 1) * line_h
	                if my >= oy and my <= oy + line_h then
	                  opt_index = i_opt
	                  break
	                end
	              end
	            end
	          end
	        end
	
	        if r_pressed and opt_index then
	          if not e.r_pressed_on then
	            e.r_pressed_on = true
	
	            if e.multi_select then
	              local set = e.selected_set or {}
	              e.selected_set = set
	              if set[opt_index] then
	                set[opt_index] = nil
	                if e.ref then
	                  local vals = {}
	                  for idx,_ in pairs(set) do
	                    local v = e.values and e.values[idx] or e.options[idx]
	                    add(vals, v)
	                  end
	                  e.ref[1] = vals
	                end
	              end
	            else
	              if e.selected == opt_index then
	                if e.default_option then
	                  e.selected = e.default_option
	                  if e.ref then
	                    local v = e.values and e.values[e.default_option] or e.options[e.default_option]
	                    e.ref[1] = v
	                  end
	                else
	                  e.selected = nil
	                  if e.ref then e.ref[1] = nil end
	                end
	              end
	            end
	            return
	          end
	        elseif r_released then
	          e.r_pressed_on = false
	        end
	
	        if not e.scroll_dragging then
	          if mouse_pressed then
	            if opt_index and not e.pressed_on then
	              e.pressed_on = true
	              auto_close_others(e)
	
	              if e.multi_select then
	                local set = e.selected_set or {}
	                e.selected_set = set
	                if set[opt_index] then set[opt_index] = nil else set[opt_index] = true end
	
	                if e.ref then
	                  local vals = {}
	                  for idx,_ in pairs(set) do
	                    local v = e.values and e.values[idx] or e.options[idx]
	                    add(vals, v)
	                  end
	                  e.ref[1] = vals
	                end
	              else
	                e.selected = opt_index
	                if e.ref then
	                  local v = e.values and e.values[opt_index] or e.options[opt_index]
	                  e.ref[1] = v
	                end
	              end
	
	              if e.func then
	                local v = e.values and e.values[opt_index] or e.options[opt_index]
	                e.func(e, opt_index, v)
	              end
	              return
	
	            elseif hovered and not e.pressed_on and not opt_index then
	              e.pressed_on = true
	              auto_close_others(e)
	              e.open = not e.open
	              return
	            elseif hovered == false then
	              e.open = false
	            end
	          elseif mouse_released then
	            e.pressed_on = false
	          end
	        end
	
	      else
	        if hovered then
	          local start_y = y
	          if mx >= x and mx <= x + e.size.w then
	            for i_opt,_ in ipairs(e.options) do
	              local row = i_opt - offset
	              if row >= 1 and row <= visible then
	                local oy = start_y + (row - 1) * line_h
	                if my >= oy and my <= oy + line_h then
	                  opt_index = i_opt
	                  break
	                end
	              end
	            end
	          end
	        end
	
	        if r_pressed and opt_index then
	          if not e.r_pressed_on then
	            e.r_pressed_on = true
	
	            if e.multi_select then
	              local set = e.selected_set or {}
	              e.selected_set = set
	              if set[opt_index] then
	                set[opt_index] = nil
	                if e.ref then
	                  local vals = {}
	                  for idx,_ in pairs(set) do
	                    local v = e.values and e.values[idx] or e.options[idx]
	                    add(vals, v)
	                  end
	                  e.ref[1] = vals
	                end
	              end
	            else
	              if e.selected == opt_index then
	                if e.default_option then
	                  e.selected = e.default_option
	                  if e.ref then
	                    local v = e.values and e.values[e.default_option] or e.options[e.default_option]
	                    e.ref[1] = v
	                  end
	                else
	                  e.selected = nil
	                  if e.ref then e.ref[1] = nil end
	                end
	              end
	            end
	            return
	          end
	        elseif r_released then
	          e.r_pressed_on = false
	        end
	
	        if not e.scroll_dragging then
	          if mouse_pressed and opt_index and not e.pressed_on then
	            e.pressed_on = true
	            auto_close_others(e)
	            e.open=false
	
	            if e.multi_select then
	              local set = e.selected_set or {}
	              e.selected_set = set
	              if set[opt_index] then set[opt_index] = nil else set[opt_index] = true end
	
	              if e.ref then
	                local vals = {}
	                for idx,_ in pairs(set) do
	                  local v = e.values and e.values[idx] or e.options[idx]
	                  add(vals, v)
	                end
	                e.ref[1] = vals
	              end
	            else
	              e.selected = opt_index
	              if e.ref then
	                local v = e.values and e.values[opt_index] or e.options[opt_index]
	                e.ref[1] = v
	              end
	            end
	
	            if e.func then
	              local v = e.values and e.values[opt_index] or e.options[opt_index]
	              e.func(e, opt_index, v)
	            end
	
	            return
	          elseif mouse_released then
	            e.pressed_on = false
	          end
	        end
	      end
	
	    else
	      ----------------------------------------------------
	      -- GENERIC CLICKABLES (buttons, containers, spr_*_button, slot)
	      ----------------------------------------------------
	      e.state = "idle"
	      local is_drag  = e.draggable
	      local can_move = (e.move == true)
	
	      if mb == 1 then
	        if is_drag then
	          ------------------------------------------------
	          -- DRAG: slot-based / inventory style
	          ------------------------------------------------
	          if mouse_pressed and hovered and not e.dragging then
	            e.pressed_on   = true
	            e.state        = "pressed"
	            e.drag_start_mx= mx
	            e.drag_start_my= my
	            e.drag_last_mx = mx
	            e.drag_last_my = my
	            e.drag_origin  = {x=e.pos.x, y=e.pos.y}
	            bring_to_front(page, e)
	          elseif e.pressed_on and not e.dragging then
	            local dx = abs(mx - (e.drag_start_mx or mx))
	            local dy = abs(my - (e.drag_start_my or my))
	            if dx + dy > drag_threshold then
	              e.dragging   = true
	              ui_drag_elem = e
	              e.state      = "pressed"
	              bring_to_front(page, e)
	            else
	              e.state = "pressed"
	            end
	          elseif e.dragging and ui_drag_elem == e then
	            local dx = mx - (e.drag_last_mx or mx)
	            local dy = my - (e.drag_last_my or my)
	            e.pos.x += dx
	            e.pos.y += dy
	            e.drag_last_mx = mx
	            e.drag_last_my = my
	            e.state = "pressed"
	          end
	
	        elseif can_move then
	          ------------------------------------------------
	          -- MOVE: layout tweak (works with arrange via move_offset)
	          ------------------------------------------------
	          if hovered and mouse_pressed and not e.moving then
	            e.pressed_on    = true
	            e.state         = "pressed"
	            e.move_start_mx = mx
	            e.move_start_my = my
	            e.move_last_mx  = mx
	            e.move_last_my  = my
	            if e.focus then bring_to_front(page, e) end
	
	          elseif e.pressed_on and not e.moving then
	            local dx = abs(mx - (e.move_start_mx or mx))
	            local dy = abs(my - (e.move_start_my or my))
	            if dx + dy > drag_threshold then
	              e.moving     = true
	              ui_drag_elem = e
	              e.state      = "pressed"
	              if e.focus then bring_to_front(page, e) end
	            else
	              e.state = "pressed"
	            end
	
	          elseif e.moving and ui_drag_elem == e then
	            local dx = mx - (e.move_last_mx or mx)
	            local dy = my - (e.move_last_my or my)
	
	            if e.arrange then
	              e.move_offset = e.move_offset or {x = 0, y = 0}
	              e.move_offset.x += dx
	              e.move_offset.y += dy
	            else
	              e.pos.x += dx
	              e.pos.y += dy
	            end
	
	            e.move_last_mx = mx
	            e.move_last_my = my
	            e.state = "pressed"
	          end
	
	        else
	          ------------------------------------------------
	          -- NORMAL CLICKABLE (no drag/move)
	          ------------------------------------------------
	          if hovered and mouse_pressed then
	            e.pressed_on = true
	            e.state = "pressed"
	
	            if not in_slot then
	              auto_close_others(e)
	              apply_upstage_pages(e)
	
	              if e.toggle_state ~= nil then
	                e.toggle_state = not e.toggle_state
	                if e.ref then e.ref[1] = e.toggle_state end
	              end
	
	              if e.focus then bring_to_front(page, e) end
	              if e.func then
	                if e.confirm then
	                  request_confirm(e)
	                else
	                  e.func(e)
	                end
	              end
	              if e.type ~= "dropdown" then
	                trigger_close(e)
	              end
	              return
	            end
	          elseif e.pressed_on then
	            e.state = "pressed"
	          end
	        end
	
	      else
	        -- mouse released or not pressed
	        if is_drag then
	          if e.dragging and ui_drag_elem == e and mouse_released then
	            drop_on_slot(page, e, mx, my)
	            e.dragging   = false
	            ui_drag_elem = nil
	            e.pressed_on = false
	            e.state = hovered and "hovered" or "idle"
	          elseif e.pressed_on and mouse_released then
	            e.state = hovered and "hovered" or "idle"
	
	            if not in_slot then
	              auto_close_others(e)
	              apply_upstage_pages(e)
	
	              if e.toggle_state ~= nil then
	                e.toggle_state = not e.toggle_state
	                if e.ref then e.ref[1] = e.toggle_state end
	              end
	
	              if e.focus then bring_to_front(page, e) end
	              if e.func then
	                if e.confirm then request_confirm(e) else e.func(e) end
	              end
	              if e.type ~= "dropdown" then trigger_close(e) end
	              e.pressed_on = false
	              return
	            else
	              e.pressed_on = false
	            end
	          else
	            if hovered then e.state = "hovered" end
	            if mouse_released then e.pressed_on = false end
	          end
	
	        elseif can_move then
	          if e.moving and ui_drag_elem == e and mouse_released then
	            e.moving     = false
	            ui_drag_elem = nil
	            e.pressed_on = false
	            e.state = hovered and "hovered" or "idle"
	
	          elseif e.pressed_on and not e.moving and mouse_released then
	            e.pressed_on = false
	            e.state = hovered and "hovered" or "idle"
	
	            if not in_slot and hovered then
	              auto_close_others(e)
	              apply_upstage_pages(e)
	
	              if e.toggle_state ~= nil then
	                e.toggle_state = not e.toggle_state
	                if e.ref then e.ref[1] = e.toggle_state end
	              end
	
	              if e.focus then bring_to_front(page, e) end
	              if e.func then
	                if e.confirm then request_confirm(e) else e.func(e) end
	              end
	              if e.type ~= "dropdown" then trigger_close(e) end
	              return
	            end
	          else
	            if hovered then e.state = "hovered" end
	            if mouse_released then e.pressed_on = false end
	          end
	
	        else
	          if hovered then e.state = "hovered" end
	          if mouse_released then e.pressed_on = false end
	        end
	      end
	
	      e.down = (e.state == "pressed")
	    end
	
	    ::after_mouse::
	
	    ----------------------------------------------------
	    -- c_func (element-element collision) in SCREEN SPACE
	    -- c_func(self, other, x, y)
	    ----------------------------------------------------
if e.c_func and ui_ids then
  for _, other in pairs(ui_ids) do
    if other ~= e and other.visible ~= false then
      local w1 = is_world(e)
      local w2 = is_world(other)

      local hit = false
      if w1 and w2 then
        hit = elems_collide_world(e, other)
      else
        hit = elems_collide_screen(e, other)
      end

      if hit then
        -- PASS HIT POINT = OTHER ELEMENT POSITION
        local wx, wy = elem_world_xy(other)
        local sx, sy = elem_draw_screen_xy(other)
        e:c_func(other, wx, wy, sx, sy)
      end
    end
  end
end


	
	    ----------------------------------------------------
	    -- PAGE-BASED SLIDE / WIPE UPDATE (toggle_string)
	    -- (skip elements managed by toggle_element)
	    ----------------------------------------------------
	    if (opening or closing) and (e.wipe or e.slide) then
	      local managed = (e.id and ui_elem_state[e.id] ~= nil)
	
	      if not managed then
	        page_has_anim = true
	
	        if e.wipe then
	          local wconf = e.wipe
	          if opening and wconf.mode ~= "opening" then
	            wconf.mode = "opening"
	            wconf.t    = 0
	          elseif closing and wconf.mode ~= "closing" then
	            wconf.mode = "closing"
	            wconf.t    = 0
	          end
	
	          if wconf.mode == "opening" or wconf.mode == "closing" then
	            local spd = wconf.speed or 0.2
	            wconf.t += spd
	            if wconf.t >= 1 then
	              wconf.t = 1
	              if opening then wconf.mode = "open"
	              elseif closing then wconf.mode = "closed" end
	            else
	              if opening then page_all_open_done  = false end
	              if closing then page_all_close_done = false end
	            end
	          end
	        end
	
	        if e.slide then
	          local s = e.slide
	          local last_state = e._last_page_state or "closed"
	          if page_state ~= last_state then
	            if opening then
	              e.slide_mode = "opening"
	              e.slide_t    = 0
	            elseif closing then
	              e.slide_mode = "closing"
	              e.slide_t    = 0
	            end
	            e._last_page_state = page_state
	          end
	
	          if e.slide_mode == "opening" then
	            local spd = e.slide_speed or 0.1
	            e.slide_t += spd
	            if e.slide_t >= 1 then
	              e.slide_t    = 1
	              e.slide_mode = "open"
	            else
	              page_all_open_done = false
	            end
	
	          elseif e.slide_mode == "closing" then
	            local spd = e.slide_speed or 0.1
	            e.slide_t += spd
	            if e.slide_t >= 1 then
	              e.slide_t    = 1
	              e.slide_mode = "closed"
	            else
	              page_all_close_done = false
	            end
	          end
	
	          local t
	          if e.slide_mode == "opening" then t = e.slide_t
	          elseif e.slide_mode == "closing" then t = 1 - e.slide_t
	          elseif e.slide_mode == "open" then t = 1
	          elseif e.slide_mode == "closed" then t = 0
	          else t = e.slide_t or 1 end
	
	          e.pos.x = lerp(s[1], s[3], t)
	          e.pos.y = lerp(s[2], s[4], t)
	        end
	      end
	    end
	
	    ----------------------------------------------------
	    -- ELEMENT-BASED SLIDE / WIPE UPDATE (toggle_element)
	    ----------------------------------------------------
	    local elem_state   = (e.id and ui_elem_state[e.id]) or nil
	    local elem_opening = (elem_state == "opening")
	    local elem_closing = (elem_state == "closing")
	
	    if (not opening and not closing)
	    and (elem_opening or elem_closing)
	    and (e.wipe or e.slide) then
	
	      if e.wipe then
	        local wconf = e.wipe
	
	        if elem_opening and wconf.mode ~= "opening" and wconf.mode ~= "open" then
	          wconf.mode = "opening"
	        elseif elem_closing and wconf.mode ~= "closing" and wconf.mode ~= "closed" then
	          wconf.mode = "closing"
	        end
	
	        if wconf.mode == "opening" then
	          local spd = wconf.speed or 0.2
	          wconf.t += spd
	          if wconf.t >= 1 then
	            wconf.t = 1
	            wconf.mode = "open"
	          end
	        elseif wconf.mode == "closing" then
	          local spd = wconf.speed or 0.2
	          wconf.t += spd
	          if wconf.t >= 1 then
	            wconf.t = 1
	            wconf.mode = "closed"
	          end
	        end
	      end
	
	      if e.slide then
	        local s = e.slide
	
	        if elem_opening and e.slide_mode ~= "opening" and e.slide_mode ~= "open" then
	          e.slide_mode = "opening"
	        elseif elem_closing and e.slide_mode ~= "closing" and e.slide_mode ~= "closed" then
	          e.slide_mode = "closing"
	        end
	
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
	        if e.slide_mode == "opening" then t = e.slide_t
	        elseif e.slide_mode == "closing" then t = 1 - e.slide_t
	        elseif e.slide_mode == "open" then t = 1
	        elseif e.slide_mode == "closed" then t = 0
	        else t = e.slide_t or 1 end
	
	        e.pos.x = lerp(s[1], s[3], t)
	        e.pos.y = lerp(s[2], s[4], t)
	      end
	    end
	
	    ----------------------------------------------------
	    -- element-level open/close finalization (for toggle_element)
	    ----------------------------------------------------
	    if e.id then
	      local st = ui_elem_state[e.id]
	      if st == "opening" then
	        if (not e.wipe or e.wipe.mode == "open")
	        and (not e.slide or e.slide_mode == "open") then
	          ui_elem_state[e.id] = "open"
	        end
	      elseif st == "closing" then
	        if (not e.wipe or e.wipe.mode == "closed")
	        and (not e.slide or e.slide_mode == "closed") then
	          ui_elem_state[e.id] = "closed"
	          e.visible = false
	        end
	      end
	    end
	
	    ----------------------------------------------------
	    -- delayed close / custom update
	    ----------------------------------------------------
	    if e._close_timer then
	      e._close_timer -= 1
	      if e._close_timer <= 0 then
	        e._close_timer = nil
	        if e.switch_on_close then
	          toggle_string(ap, 1, e.switch_on_close)
	        end
	      end
	    end
	
	    if e.update then e:update() end
	
	    ::skip::
	  end
	
	  ----------------------------------------------------
	  -- PAGE STATE FINALIZATION (for toggle_string)
	  ----------------------------------------------------
	  page_state = ui_page_state[page]
	
	  if page_state == "opening" then
	    if (not page_has_anim) or page_all_open_done then
	      ui_page_state[page] = "open"
	      if ui[page] then
	        for e in all(ui[page]) do
	          local managed = (e.id and ui_elem_state[e.id] ~= nil)
	          if not managed then
	            if e.wipe then
	              e.wipe.mode = "open"
	              e.wipe.t    = 1
	            end
	            if e.slide then
	              e.slide_mode = "open"
	              e.slide_t    = 1
	              local s = e.slide
	              if s then
	                e.pos.x = s[3]
	                e.pos.y = s[4]
	              end
	            end
	            e._last_page_state = "open"
	          end
	        end
	      end
	    end
	
	  elseif page_state == "closing" then
	    if (not page_has_anim) or page_all_close_done then
	      ui_page_state[page] = "closed"
	      if ap then
	        for i = #ap, 1, -1 do
	          if ap[i] == page then
	            deli(ap, i)
	            break
	          end
	        end
	      end
	      if ui[page] then
	        for e in all(ui[page]) do
	          local managed = (e.id and ui_elem_state[e.id] ~= nil)
	          if not managed then
	            if e.wipe then
	              e.wipe.mode = "closed"
	              e.wipe.t    = 1
	            end
	            if e.slide then
	              e.slide_mode = "closed"
	              e.slide_t    = 1
	              local s = e.slide
	              if s then
	                e.pos.x = s[1]
	                e.pos.y = s[2]
	              end
	            end
	            e._last_page_state = "closed"
	          end
	        end
	      end
	    end
	  end
	
	  ui_page_prev_state[page] = ui_page_state[page]
	end
	
	
	
	
	
	
	
	
	
	
	----------------------------------------------------------------
	-- d_element
	-- NOTE: camera/world-space support
	--  - assumes get_abs_pos(e) returns WORLD abs position (parent-resolved)
	--  - elements with e.world=true (or e.space=="world") are drawn in SCREEN
	--    by subtracting cam.x/cam.y
	--  - UI elements (default) ignore cam
	----------------------------------------------------------------
	function d_element(page)
	  if not ui[page] then return end
	
	  local mx, my = mouse()
	
	  cam = cam or {x=0,y=0}
	
	  local function is_world(e)
	    return (e and (e.world == true or e.space == "world"))
	  end
	
	  local function elem_world_xy(e)
	    return get_abs_pos(e)
	  end
	
	  local function elem_screen_xy(e)
	    local x, y = elem_world_xy(e)
	    if is_world(e) then
	      x -= cam.x or 0
	      y -= cam.y or 0
	    end
	    return x, y
	  end
	
	  ------------------------------------------------
	  -- pass 1: find topmost hovered element
	  ------------------------------------------------
	  local top_e   = nil
	  local top_opt = nil
	
	  for i = #ui[page], 1, -1 do
	    local e = ui[page][i]
	    if e and e.visible ~= false then
	      local x, y = elem_screen_xy(e)
	
	      -- hover animation offset (visual space)
	      if e.hover_anim_type then
	        x += e.hover_offset_x or 0
	        y += e.hover_offset_y or 0
	      end
	
	
	
	      -- element_offset affects hit detection + built-in visuals
	      if e.element_offset then
	        x += e.element_offset.x or 0
	        y += e.element_offset.y or 0
	      end
	
	-- PASS 1 (topmost hovered): right after hover animation offset, add:
	      if e.anim_type then
	        x += e.anim_offset_x or 0
	        y += e.anim_offset_y or 0
	      end
	
	      local hovered = false
	      if e.type == "c_button" or e.type == "spr_c_button" then
	        hovered = ((mx - x)^2 + (my - y)^2) < ((e.r or 8)^2)
	      elseif e.type == "slider" then
	        hovered = mx >= x - e.fw / 2 and mx <= x + e.fw / 2
	               and my >= y - e.fh / 2 and my <= y + e.fh / 2
	      else
	        local w, h = e.size.w, e.size.h
	        hovered = mx >= x and mx <= x + w and my >= y and my <= y + h
	      end
	
	      local opt_index = nil
	
	      -- dropdown options hover
	      if e.type == "dropdown" and e.open and e.options then
	        local pad_y  = (e.padding and e.padding.y) or e.size.h
	        local line_h = pad_y
	        local start_y= y + e.size.h
	        local offset = e.scroll_offset or 0
	        local visible = e.scroll_items or #e.options
	
	        for i_opt,_ in ipairs(e.options) do
	          local row = i_opt - offset
	          if row >= 1 and row <= visible then
	            local oy = start_y + (row - 1) * line_h
	            if mx >= x and mx <= x + e.size.w
	            and my >= oy and my <= oy + line_h then
	              hovered  = true
	              opt_index= i_opt
	              break
	            end
	          end
	        end
	      end
	
	      -- radio options hover
	      if e.type == "radio" and e.options then
	        local pad_y  = (e.padding and e.padding.y) or 8
	        local line_h = pad_y
	        local offset = e.scroll_offset or 0
	        local visible = e.scroll_items or #e.options
	
	        if e.dropdown then
	          if e.open then
	            local start_y = y + e.size.h
	            if mx >= x and mx <= x + e.size.w then
	              for i_opt,_ in ipairs(e.options) do
	                local row = i_opt - offset
	                if row >= 1 and row <= visible then
	                  local oy = start_y + (row - 1) * line_h
	                  if my >= oy and my <= oy + line_h then
	                    hovered  = true
	                    opt_index= i_opt
	                    break
	                  end
	                end
	              end
	            end
	          end
	        else
	          local start_y = y
	          if mx >= x and mx <= x + e.size.w then
	            for i_opt,_ in ipairs(e.options) do
	              local row = i_opt - offset
	              if row >= 1 and row <= visible then
	                local oy = start_y + (row - 1) * line_h
	                if my >= oy and my <= oy + line_h then
	                  hovered  = true
	                  opt_index= i_opt
	                  break
	                end
	              end
	            end
	          end
	        end
	      end
	
	      if hovered then
	        if ui_drag_elem then
	          -- while dragging, only slots get top hover (for highlight)
	          if e.type == "slot" then
	            top_e   = e
	            top_opt = opt_index
	            break
	          end
	        else
	          top_e   = e
	          top_opt = opt_index
	          break
	        end
	      end
	    end
	  end
	
	  ------------------------------------------------
	  -- pass 2: draw
	  ------------------------------------------------
	  for e in all(ui[page]) do
	    if not e or e.visible == false then goto skip end
	
	    local ox = e.offset and e.offset.x or 0
	    local oy = e.offset and e.offset.y or 0
	
	    local x, y = elem_screen_xy(e)
	    local is_top = (e == top_e)
	
	    -- element shake (visual only)
	    if e.shake and e.shake.t and e.shake.t > 0 then
	      local a = e.shake.amt or 2
	      x += rnd(a * 2) - a
	      y += rnd(a * 2) - a
	      e.shake.t -= 1
	      if e.shake.t <= 0 then e.shake = nil end
	    end
	
	    -- hover animation offset (visual only)
	    if e.hover_anim_type then
	      x += e.hover_offset_x or 0
	      y += e.hover_offset_y or 0
	    end
	
	-- PASS 2 (draw): right after hover animation offset, add:
	    if e.anim_type then
	      x += e.anim_offset_x or 0
	      y += e.anim_offset_y or 0
	    end
	
	    -- element_offset affects built-in visuals & wipe
	    if e.element_offset then
	      x += e.element_offset.x or 0
	      y += e.element_offset.y or 0
	    end
	
	    ------------------------------------------------
	    -- WIPE CLIP
	    ------------------------------------------------
	    local clip_applied = false
	    if e.wipe then
	      local wconf = e.wipe
	      if wconf.mode == "closed" then
	        goto skip
	      end
	
	      local t = wconf.t or 1
	      if wconf.mode == "closing" then
	        t = 1 - t
	      end
	
	      if t < 1 then
	        clip_applied = true
	
	        local bx, by, bw, bh
	        if e.type == "c_button" or e.type == "spr_c_button" then
	          local r = e.r or 8
	          bx = x - r
	          by = y - r
	          bw = r * 2 + 1
	          bh = r * 2 + 1
	        else
	          bx = x
	          by = y
	          bw = e.size.w + 1
	          bh = e.size.h + 1
	        end
	
	        local cx, cy, cw, ch = bx, by, bw, bh
	        local dir = wconf.dir or "left"
	
	        if dir == "left" then
	          cw = max(1, flr(bw * t))
	        elseif dir == "right" then
	          cw = max(1, flr(bw * t))
	          cx = bx + (bw - cw)
	        elseif dir == "up" then
	          ch = max(1, flr(bh * t))
	        elseif dir == "down" then
	          ch = max(1, flr(bh * t))
	          cy = by + (bh - ch)
	        end
	
	        clip(cx, cy, cw, ch)
	      end
	    end
	
	    local col = e.col and (e.col[1] or 1) or 1
	    local out = e.col and (e.col[2] or col) or col
	
	    if e.toggle_state ~= nil then
	      if e.toggle_state then
	        if e.toggle_on_fill then col = e.toggle_on_fill end
	        if e.toggle_on_out  then out = e.toggle_on_out  end
	      else
	        if e.toggle_off_fill then col = e.toggle_off_fill end
	        if e.toggle_off_out  then out = e.toggle_off_out  end
	      end
	    end
	
	    if e.down then
	      col = (e.col and (e.col[5] or col)) or col
	      out = (e.col and (e.col[6] or out)) or out
	    elseif is_top and (e.type ~= "dropdown" or top_opt == nil) and e.type ~= "radio" then
	      col = (e.col and (e.col[3] or col)) or col
	      out = (e.col and (e.col[4] or out)) or out
	    end
	
	    ------------------------------------------------
	    -- MAIN GEOMETRY
	    ------------------------------------------------
	    if e.type == "r_button" then
	      if not e.hide then
	        local x1 = x
	        local y1 = y
	        local x2 = x + e.size.w
	        local y2 = y + e.size.h
	
	        if e.hover_anim_type == "pulse" and is_top and (top_opt == nil) then
	          local s  = e.pulse_scale or 1
	          local cx = (x1 + x2) * 0.5
	          local cy = (y1 + y2) * 0.5
	          local hw = (x2 - x1) * 0.5 * s
	          local hh = (y2 - y1) * 0.5 * s
	          x1 = cx - hw
	          x2 = cx + hw
	          y1 = cy - hh
	          y2 = cy + hh
	        end
	
	        local w = x2 - x1
	        local h = y2 - y1
	
	        if e.rrect then
	          rrectfill(x1, y1, w, h, e.rrect, col)
	          rrect(x1, y1,  w, h, e.rrect, out)
	        elseif e.bullnose then
	          bnrectfill(x1, y1, w, h, e.bullnose, col)
	          bnrect(x1, y1,  w, h, e.bullnose, out)
	        else
	          rectfill(x1, y1, x2, y2, col)
	          rect(x1, y1, x2, y2, out)
	        end
	      end
	
	    elseif e.type == "c_button" then
	      if not e.hide then
	        local r = e.r or 8
	        if e.hover_anim_type == "pulse" and is_top and (top_opt == nil) then
	          r = r * (e.pulse_scale or 1)
	        end
	        circfill(x, y, r, col)
	        circ(x, y, r, out)
	      end
	
	    elseif e.type == "spr_r_button" then
	      local s_idle         = e.sprites and e.sprites[1]
	      local s_hover        = e.sprites and e.sprites[2] or s_idle
	      local s_active       = e.sprites and e.sprites[3] or s_hover
	      local s_hover_active = e.sprites and e.sprites[4] or s_active
	
	      local is_toggle = (e.toggle_state ~= nil)
	      local hovered   = (is_top and (top_opt == nil))
	
	      local active = is_toggle and e.toggle_state or e.down
	      local frame = s_idle
	
	      if active then
	        frame = hovered and (s_hover_active or s_active or s_hover or s_idle) or (s_active or s_hover or s_idle)
	      else
	        frame = hovered and (s_hover or s_idle) or s_idle
	      end
	
	      if frame and not e.hide then
	        spr(frame, x, y)
	      end
	
	    elseif e.type == "spr_c_button" then
	      local s_idle         = e.sprites and e.sprites[1]
	      local s_hover        = e.sprites and e.sprites[2] or s_idle
	      local s_active       = e.sprites and e.sprites[3] or s_hover
	      local s_hover_active = e.sprites and e.sprites[4] or s_active
	
	      local is_toggle = (e.toggle_state ~= nil)
	      local hovered   = (is_top and (top_opt == nil))
	
	      local active = is_toggle and e.toggle_state or e.down
	      local frame = s_idle
	
	      if active then
	        frame = hovered and (s_hover_active or s_active or s_hover or s_idle) or (s_active or s_hover or s_idle)
	      else
	        frame = hovered and (s_hover or s_idle) or s_idle
	      end
	
	      if frame and not e.hide then
	        local sw = (e.size and e.size.w) or (e.r or 8)
	        local sh = (e.size and e.size.h) or (e.r or 8)
	        local hx = flr(sw / 2)
	        local hy = flr(sh / 2)
	        spr(frame, x - hx, y - hy)
	      end
	
	    elseif e.type == "radio" then
	      if not e.hide and e.options then
	        local pad_x  = (e.padding and e.padding.x) or 4
	        local pad_y  = (e.padding and e.padding.y) or 8
	        local line_h = pad_y
	        local marker_r = 2
	        local offset = e.scroll_offset or 0
	        local total  = #e.options
	        local visible_n = e.scroll_items or total
	
	        if e.dropdown then
	          -- header
	          local header_bg = col
	          local header_bd = out
	          local header_hover = (e == top_e and top_opt == nil)
	          if header_hover then
	            header_bg = e.col[3] or header_bg
	            header_bd = e.col[4] or header_bd
	          end
	
	          local w = e.size.w
	          local h = e.size.h
	          if e.rrect then
	            rrectfill(x, y, w, h, e.rrect, header_bg)
	            rrect(x, y,  w, h, e.rrect, header_bd)
	          elseif e.bullnose then
	            bnrectfill(x, y, w, h, e.bullnose, header_bg)
	            bnrect(x, y,  w, h, e.bullnose, header_bd)
	          else
	            rectfill(x, y, x + w, y + h, header_bg)
	            rect(x, y, x + w, y + h, header_bd)
	          end
	
	          local display_label = e.label or ""
	          local selected_text = ""
	          if not e.multi_select and e.selected then
	            local v = e.options[e.selected]
	            selected_text = " : "..tostr(v)
	          end
	
	          if e.display_selected==true then
	            print(display_label..selected_text, x + pad_x, y + 2, e.label_col)
	          else
	            print(display_label, x + pad_x, y + 2, e.label_col)
	          end
	
	          if e.open then
	            local start_y = y + e.size.h
	            local visible = min(total, visible_n)
	            local list_top    = start_y
	            local list_bottom = start_y + visible * line_h
	
	            for i_opt, label in ipairs(e.options) do
	              local row = i_opt - offset
	              if row >= 1 and row <= visible then
	                local oy2 = start_y + (row - 1) * line_h
	                local hovered_item = (e == top_e and top_opt == i_opt)
	
	                local active_item
	                if e.multi_select then
	                  active_item = e.selected_set and e.selected_set[i_opt]
	                else
	                  active_item = (e.selected == i_opt)
	                end
	
	                local bg = hovered_item and (e.col[5] or col) or col
	                local bd = hovered_item and (e.col[6] or out) or out
	
	                rectfill(x, oy2, x + e.size.w, oy2 + line_h, bg)
	                rect(x, oy2, x + e.size.w, oy2 + line_h, bd)
	
	                circ(x + pad_x, oy2 + flr(line_h/2), marker_r, bd)
	                if active_item then
	                  circfill(x + pad_x, oy2 + flr(line_h/2), marker_r - 1, bd)
	                end
	
	                print(label, x + pad_x + marker_r * 2 + 2, oy2+line_h/3, e.label_col)
	              end
	            end
	
	            if e.scroll_items and total > visible_n then
	              local track_w = e.scroll_handle_w or 4
	              local track_x1 = x + e.size.w - track_w
	              local track_x2 = x + e.size.w
	              local track_y1 = list_top
	              local track_y2 = list_bottom
	              local track_h  = track_y2 - track_y1
	
	              local max_offset = max(1, total - visible_n)
	              local handle_h = max(4, flr(track_h * visible_n / total))
	              local ratio = (e.scroll_offset or 0) / max_offset
	              if ratio < 0 then ratio = 0 end
	              if ratio > 1 then ratio = 1 end
	              local handle_y1 = track_y1 + flr((track_h - handle_h) * ratio)
	              local handle_y2 = handle_y1 + handle_h
	
	              local hc  = e.scroll_handle_col or 6
	              local hco = e.scroll_handle_out or 0
	
	              rectfill(track_x1, track_y1, track_x2, track_y2, 0)
	              rect(track_x1, track_y1, track_x2, track_y2, hco)
	              rectfill(track_x1, handle_y1, track_x2, handle_y2, hc)
	            end
	          end
	
	        else
	          -- classic vertical radio
	          local start_y = y
	          local visible = min(total, visible_n)
	          local list_top    = start_y
	          local list_bottom = start_y + visible * line_h
	
	          for i_opt, label in ipairs(e.options) do
	            local row = i_opt - offset
	            if row >= 1 and row <= visible then
	              local oy2  = start_y + (row - 1) * line_h
	              local hovered_item = (e == top_e and top_opt == i_opt)
	
	              local active_item
	              if e.multi_select then
	                active_item = e.selected_set and e.selected_set[i_opt]
	              else
	                active_item = (e.selected == i_opt)
	              end
	
	              local bg = hovered_item and (e.col[3] or col) or col
	              local bd = hovered_item and (e.col[4] or out) or out
	
	              circ(x + pad_x, oy2 + flr(line_h/2), marker_r, bd)
	              if active_item then
	                circfill(x + pad_x, oy2 + flr(line_h/2), marker_r - 1, bd)
	              end
	
	              print(label, x + pad_x + marker_r * 2 + 2, oy2+line_h/3, e.label_col)
	            end
	          end
	
	          if e.scroll_items and total > visible_n then
	            local track_w = e.scroll_handle_w or 2
	            local track_x1 = x + e.size.w - track_w
	            local track_x2 = x + e.size.w
	            local track_y1 = list_top
	            local track_y2 = list_bottom
	            local track_h  = track_y2 - track_y1
	
	            local max_offset = max(1, total - visible_n)
	            local handle_h = max(4, flr(track_h * visible_n / total))
	            local ratio = (e.scroll_offset or 0) / max_offset
	            if ratio < 0 then ratio = 0 end
	            if ratio > 1 then ratio = 1 end
	            local handle_y1 = track_y1 + flr((track_h - handle_h) * ratio)
	            local handle_y2 = handle_y1 + handle_h
	
	            local hc  = e.scroll_handle_col or 6
	            local hco = e.scroll_handle_out or 0
	
	            rectfill(track_x1, track_y1, track_x2, track_y2, 0)
	            rect(track_x1, track_y1, track_x2, track_y2, hco)
	            rectfill(track_x1, handle_y1, track_x2, handle_y2, hc)
	          end
	        end
	      end
	
	    elseif e.type == "slider" then
	      local val  = (e.ref and e.ref[1]) or 0
	      local maxv = e.max or 1
	      local track_x1 = x - e.fw / 2
	      local track_x2 = x + e.fw / 2
	      local thumb_x  = track_x1 + (val / maxv) * e.fw
	
	      if not e.hide then
	        line(track_x1, y, track_x2, y, out)
	        circfill(thumb_x, y, e.fh or 4, col)
	      end
	      print(tostr(val), track_x2 + 4, y - 3, 7)
	
	    elseif e.type == "dropdown" then
	      local pad_x  = (e.padding and e.padding.x) or 2
	      local pad_y  = (e.padding and e.padding.y) or e.size.h
	      local line_h = pad_y
	
	      -- header
	      if not e.hide then
	        local w = e.size.w
	        local h = e.size.h
	        if e.rrect then
	          rrectfill(x, y, w, h, e.rrect, col)
	          rrect(x, y,  w, h, e.rrect, out)
	        elseif e.bullnose then
	          bnrectfill(x, y, w, h, e.bullnose, col)
	          bnrect(x, y,  w, h, e.bullnose, out)
	        else
	          rectfill(x, y, x + w, y + h, col)
	          rect(x, y, x + w, y + h, out)
	        end
	      end
	
	      local caption = e.label or "label"
	      local current = e.options and e.options[e.selected] or ""
	
	      if e.display_selected == true then
	        print(caption..": "..current, x + pad_x, y + 2, 7)
	      else
	        print(caption, x + pad_x, y + 2, 7)
	      end
	
	      -- open list
	      if e.open and e.options then
	        local start_y = y + e.size.h
	        local offset  = e.scroll_offset or 0
	        local total   = #e.options
	        local visible_n = e.scroll_items or total
	        local visible = min(total, visible_n)
	        local list_top    = start_y
	        local list_bottom = start_y + visible * line_h
	
	        for i_opt, label in ipairs(e.options) do
	          local row = i_opt - offset
	          if row >= 1 and row <= visible then
	            local oy2 = start_y + (row - 1) * line_h
	            local hovered_item = (e == top_e and top_opt == i_opt)
	
	            local bg = hovered_item and (e.col[3] or col) or col
	            local bd = hovered_item and (e.col[4] or out) or out
	
	            if not e.hide then
	              rectfill(x, oy2, x + e.size.w, oy2 + line_h, bg)
	              rect(x, oy2, x + e.size.w, oy2 + line_h, bd)
	            end
	            print(label, x + pad_x, oy2 + line_h/3 + 2, e.label_col)
	          end
	        end
	
	        if e.scroll_items and total > visible_n then
	          local track_w = e.scroll_handle_w or 2
	          local track_x1 = x + e.size.w - track_w
	          local track_x2 = x + e.size.w
	          local track_y1 = list_top
	          local track_y2 = list_bottom
	          local track_h  = track_y2 - track_y1
	
	          local max_offset = max(1, total - visible_n)
	          local handle_h = max(4, flr(track_h * visible_n / total))
	          local ratio = (e.scroll_offset or 0) / max_offset
	          if ratio < 0 then ratio = 0 end
	          if ratio > 1 then ratio = 1 end
	          local handle_y1 = track_y1 + flr((track_h - handle_h) * ratio)
	          local handle_y2 = handle_y1 + handle_h
	
	          local hc  = e.scroll_handle_col or 6
	          local hco = e.scroll_handle_out or 0
	
	          rectfill(track_x1, track_y1, track_x2, track_y2, 0)
	          rect(track_x1, track_y1, track_x2, track_y2, hco)
	          rectfill(track_x1, handle_y1, track_x2, handle_y2, hc)
	        end
	      end
	
	    elseif e.type == "container" then
	      if not e.hide then
	        if not out then out = col end
	        local w = e.size.w
	        local h = e.size.h
	        if e.rrect then
	          rrectfill(x, y, w, h, e.rrect, col)
	          rrect(x, y,  w, h, e.rrect, out)
	        elseif e.bullnose then
	          bnrectfill(x, y, w, h, e.bullnose, col)
	          bnrect(x, y,  w, h, e.bullnose, out)
	        else
	          rectfill(x, y, x + w, y + h, col)
	          rect(x, y, x + w, y + h, out)
	        end
	      end
	
	    elseif e.type == "spr_container" then
	      if not e.hide then
	        local s_idle   = e.sprites and e.sprites[1]
	        local s_hover  = e.sprites and e.sprites[2] or s_idle
	        local s_active = e.sprites and e.sprites[3] or s_hover
	
	        local hovered = (is_top and (top_opt == nil))
	        local frame   = s_idle
	
	        if e.down then
	          frame = s_active or s_hover or s_idle
	        elseif hovered then
	          frame = s_hover or s_idle
	        end
	
	        if frame then
	          spr_container(frame, x, y, e.size.w, e.size.h)
	        end
	      end
	
	    elseif e.type == "slot" then
	      if not e.hide then
	        local frame_col = out or col
	        local hover_with_drag = (ui_drag_elem ~= nil and is_top)
	        local w = e.size.w
	        local h = e.size.h
	
	        if e.rrect then
	          rrect(x, y, w, h, e.rrect, frame_col)
	          if e.held or hover_with_drag then
	            rrectfill(x+1, y+1, w-2, h-2, max(0, e.rrect-1), col)
	          end
	        elseif e.bullnose then
	          bnrect(x, y, w, h, e.bullnose, frame_col)
	          if e.held or hover_with_drag then
	            bnrectfill(x+1, y+1, w-2, h-2, max(0, e.bullnose-1), col)
	          end
	        else
	          rect(x, y, x + w, y + h, frame_col)
	          if e.held or hover_with_drag then
	            rectfill(x+1, y+1, x + w-1, y + h-1, col)
	          end
	        end
	      end
	    end
	
	    ------------------------------------------------
	    -- LABEL
	    ------------------------------------------------
	    if e.label and type(e.label) == "string"
	    and #e.label > 0
	    and e.type ~= "slider"
	    and e.type ~= "dropdown"
	    and e.type ~= "radio" then
	      print(e.label, x + 2 + ox, y + 2 + oy, e.label_col)
	    end
	
	    ------------------------------------------------
	    -- CUSTOM DRAW (supports draw_offset = {x=,y=})
	    ------------------------------------------------
	    if e.draw then
	      local dx, dy = x, y
	      if e.draw_offset then
	        dx += e.draw_offset.x or 0
	        dy += e.draw_offset.y or 0
	      end
	      e:draw(dx, dy)
	    end
	
	    if clip_applied then clip() end
	
	    ::skip::
	  end
	
	  ------------------------------------------------
	  -- TOOLTIP
	  ------------------------------------------------
	  if top_e and top_e.tooltip then
	    local tt    = top_e.tooltip
	    local body  = tt[1]
	
	    if body ~= nil then
	      local delay = tt[2] or 15
	      local w     = tt[3]
	      local h     = tt[4]
	      local tc    = tt[5] or 7
	      local bg    = tt[6]
	      local outl  = tt[7]
	
	      if (top_e.hover_t or 0) >= delay then
	        if (not w or not h) then
	          if type(body) == "string" then
	            local tw = #body * 4
	            local th = 6
	            w = w or (tw + 4)
	            h = h or (th + 4)
	          else
	            w = w or 64
	            h = h or 24
	          end
	        end
	
	        local tx = mx + 4
	        local ty = my + 4
	
	        if bg then
	          rectfill(tx, ty, tx + w, ty + h, bg)
	          if outl == nil then outl = bg end
	        end
	        if outl then
	          rect(tx, ty, tx + w, ty + h, outl)
	        end
	
	        if type(body) == "function" then
	          body(top_e, tx + 2, ty + 2)
	        else
	          print(body, tx + 2, ty + 2, tc)
	        end
	      end
	    end
	  end
	end
