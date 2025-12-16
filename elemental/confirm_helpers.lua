	-- ============================================================
	-- GLOBAL CONFIRM HELPERS (no boilerplate for end user)
	-- ============================================================
	confirm_state = confirm_state or {
	    target  = nil,
	    func    = nil,
	    message = nil
	}
	
	local function clear_confirm_state()
	    confirm_state.target  = nil
	    confirm_state.func    = nil
	    confirm_state.message = nil
	end
	
	function confirm_yes()
	    if confirm_state.func and confirm_state.target then
	        -- run the original button's func
	        confirm_state.func(confirm_state.target)
	    end
	    clear_confirm_state()
	    if ap then
	        toggle_strings(ap, "confirm_dialogue")
	    end
	end
	
	function confirm_no()
	    clear_confirm_state()
	    if ap then
	        toggle_strings(ap, "confirm_dialogue")
	    end
	end
	
	function ensure_confirm_dialog()
	    ui      = ui      or {}
	    ui_ids  = ui_ids  or {}
	
	    if ui["confirm_dialogue"] and ui_ids["confirm_yes"] and ui_ids["confirm_no"] then
	        return
	    end
	
	    -- background
	    local bg = i_element({
	        page   = "confirm_dialogue",
	        type   = "container",
	        id     = "confirm_dialogue_main",
	        label  = "confirm:",
	        offset = {x=10},
	        pos    = {x=160,y=80},
	        size   = {w=100,h=40},
	        colors = {2,7},
	        bullnose = 9
	    })
	
	    -- yes
	    local yes = i_element({
	        page    = "confirm_dialogue",
	        type    = "r_button",
	        id      = "confirm_yes",
	        label   = "yes",
	        offset  = {x=8},
	        bullnose= 4,
	        arrange = {"confirm_dialogue_main",10,15},
	        size    = {w=35,h=12},
	        colors  = {1, 1},
	        func    = function(self)
	            confirm_yes()
	        end
	    })
	
	    -- no
	    local no = i_element({
	        page    = "confirm_dialogue",
	        type    = "r_button",
	        id      = "confirm_no",
			  offset  = {x=12},
	        label   = "no",
	        bullnose= 4,
	        arrange = {"confirm_yes",47,0},
	        size    = {w=35,h=12},
	        colors  = {1, 1},
	        func    = function(self)
	            confirm_no()
	        end
	    })
	
	    -- PRE-ARRANGE so first draw uses correct positions
	    if auto_arrange then
	        if yes.arrange then auto_arrange(yes) end
	        if no.arrange  then auto_arrange(no)  end
	    end
	
	    -- ????? FORCE CLEAN INPUT STATE so they don't flash as "pressed" or "hovered"
	    yes.state        = "idle"
	    yes.down         = false
	    yes.pressed_on   = false
	    yes.hover_t      = 0
	    yes.r_pressed_on = false
	
	    no.state         = "idle"
	    no.down          = false
	    no.pressed_on    = false
	    no.hover_t       = 0
	    no.r_pressed_on  = false
	
	end
	
	
	
	function request_confirm(e)
	    confirm_state.target  = e
	    confirm_state.func    = e.func
	    confirm_state.message = e.confirm_msg or ("confirm: "..(e.label or ""))
	
	    ensure_confirm_dialog()
	
	    if ui_ids and ui_ids["confirm_dialogue_main"] then
	        ui_ids["confirm_dialogue_main"].label = confirm_state.message
	    end
	
	    if ap then
	        toggle_strings(ap, "confirm_dialogue")
	    end
	end
	
	---
