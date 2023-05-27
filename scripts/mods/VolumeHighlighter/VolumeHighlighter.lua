--[[
    author: Uganda (Axel Joly)
    -----
    Copyright © 2023, Uganda
    Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
    The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
    The Software is provided “as is”, without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose and noninfringement. In no event shall the authors or copyright holders X be liable for any claim, damages or other liability, whether in an action of contract, tort or otherwise, arising from, out of or in connection with the software or the use or other dealings in the Software.
    Except as contained in this notice, the name of the <copyright holders> shall not be used in advertising or otherwise to promote the sale, use or other dealings in this Software without prior written authorization from the <copyright holders>. »
    -----
--]]

-------------------
-- LUA UTILITIES --

-- for key,value in pairs(input_manager) do
    -- print(key, value)
-- end
-- for key,value in pairs(getmetatable(input_manager)) do
    -- print(key, value)
-- end

-- for i,v in pairs(input_manager) do print(i,v) end

-- print("x = " .. tostring(x))

-- LUA UTILITIES --
-------------------

local new_poly = require("scripts/mods/VolumeHighlighter/poly")

local mod = get_mod("VolumeHighlighter")

-- Boolean
mod.is_ingame = false

-- Globals
mod.gui = nil
mod.id = nil

-- Modifications
script_data.debug_enabled = true
script_data.force_debug_disabled = false
script_data.disable_debug_draw = false
Development._hardcoded_dev_params.force_debug_disabled = false
Development._hardcoded_dev_params.disable_debug_draw = false

DebugManager.drawer = function (self, options)
	options = options or {}
	local drawer_name = options.name
	local drawer = nil
	local drawer_api = DebugDrawer

	if drawer_name == nil then
		local line_object = World.create_line_object(self._world)
		drawer = drawer_api.new(drawer_api, line_object, options.mode)
		self._drawers[#self._drawers + 1] = drawer
	elseif self._drawers[drawer_name] == nil then
		local line_object = World.create_line_object(self._world)
		drawer = drawer_api.new(drawer_api, line_object, options.mode)
		self._drawers[drawer_name] = drawer
	else
		drawer = self._drawers[drawer_name]
	end

	return drawer
end

------------
-- EVENTS --

mod.on_game_state_changed = function(status, state_name)
    if status == "enter" and state_name == "StateIngame" then
        mod.is_ingame = true
    elseif status == "exit" and state_name == "StateIngame" then
        QuickDrawer:reset()
        QuickDrawerStay:reset()
        mod.is_ingame = false
	else
		mod.is_ingame = false
    end
end

mod.update = function(dt)
    if mod.is_ingame then
        if Managers.player:local_player() then
            if Managers.player:local_player().player_unit then
                if Managers.state.debug then
                    for _, drawer in pairs(Managers.state.debug._drawers) do
                        drawer.update(drawer, Managers.state.debug._world)
                    end
                end
            end
        end
    end
end

-- EVENTS --
------------

--------------------
-- USER FUNCTIONS --

-- Called function from keybind
mod.highlight_collision = function (self)
    local local_player = Managers.player:local_player()
    local viewport_name = local_player.viewport_name
    local camera_position = Managers.state.camera:camera_position(viewport_name)
    local camera_rotation = Managers.state.camera:camera_rotation(viewport_name)
    local camera_direction = Quaternion.forward(camera_rotation)
    local left_right = Quaternion.right(camera_rotation)
    local up_down = Quaternion.up(camera_rotation)
    local world = Managers.world:world("level_world")
    local physics_world = World.get_data(world, "physics_world")
    local position
    local is_hit, hit_pos, hit_norm
    
    local color_collision = Color(mod:get("collision_alpha"), mod:get("collision_red"), mod:get("collision_green"), mod:get("collision_blue")) or Color(255, 255, 255, 255)
    local line = mod:get("collision_line_number")
    local column = mod:get("collision_column_number")
    
    
    local range = mod:get("collision_fwd_dist")
    
    if (line % 2 == 0) and (column % 2 == 0) then
        line = math.floor(line / 2) - 0.5
        column = math.floor(column / 2) - 0.5
    elseif (line % 2 == 0) and not (column % 2 == 0) then
        line = math.floor(line / 2) - 0.5
        column = math.floor(column / 2)
    elseif not (line % 2 == 0) and (column % 2 == 0) then
        line = math.floor(line / 2)
        column = math.floor(column / 2) - 0.5
    else
        line = math.floor(line / 2)
        column = math.floor(column / 2)
    end
    
    for i=-line, line, 1 do
        for j=-column, column, 1 do
            local ii = (mod:get("collision_line_inter_dist") * i) / 100
            local jj = (mod:get("collision_column_inter_dist") * j) / 100
            position = Vector3(camera_position["x"] + jj*left_right["x"] + ii*up_down["x"], camera_position["y"] + jj*left_right["y"] + ii*up_down["y"], camera_position["z"] + jj*left_right["z"] + ii*up_down["z"])
            is_hit, hit_pos, _, hit_norm, _ = PhysicsWorld.immediate_raycast(physics_world, position, camera_direction, range, "closest", "collision_filter", "filter_player_mover")
            if is_hit then
                QuickDrawerStay:circle(hit_pos, 0.1, hit_norm, color_collision)
                QuickDrawerStay:vector(hit_pos, hit_norm * 0.1, color_collision)
            end
        end
    end
end

function draw_polygon (polygone)
    local world = Managers.world:world("level_world")
    local gui = mod.gui
    
    local shape = {}
    shape.poly = new_poly()
    for i = 1, #polygone, 1 do
        shape.poly:push_coord(polygone[i][1], polygone[i][2])
    end
    shape.poly:close()
    if shape.poly:is_closed() then
        shape.is_convex = shape.poly:is_convex()
        shape.is_cw_winding = shape.poly:is_cw()
        shape.triangles = shape.poly:get_triangles()
    end
    
    for _,triangle in ipairs(shape.triangles) do
        Gui.triangle(gui, Vector3(polygone[triangle[1]][1], polygone[triangle[1]][2], polygone[triangle[1]][3]), Vector3(polygone[triangle[2]][1], polygone[triangle[2]][2], polygone[triangle[2]][3]), Vector3(polygone[triangle[3]][1], polygone[triangle[3]][2], polygone[triangle[3]][3]), 2, Color(100, mod:get("deathwall_red"), mod:get("deathwall_green"), mod:get("deathwall_blue")))
        QuickDrawerStay:line(Vector3(polygone[triangle[1]][1], polygone[triangle[1]][2], polygone[triangle[1]][3]), Vector3(polygone[triangle[2]][1], polygone[triangle[2]][2], polygone[triangle[2]][3]), Color(255, mod:get("deathwall_red"), mod:get("deathwall_green"), mod:get("deathwall_blue")))
        QuickDrawerStay:line(Vector3(polygone[triangle[2]][1], polygone[triangle[2]][2], polygone[triangle[2]][3]), Vector3(polygone[triangle[3]][1], polygone[triangle[3]][2], polygone[triangle[3]][3]), Color(255, mod:get("deathwall_red"), mod:get("deathwall_green"), mod:get("deathwall_blue")))
        QuickDrawerStay:line(Vector3(polygone[triangle[3]][1], polygone[triangle[3]][2], polygone[triangle[3]][3]), Vector3(polygone[triangle[1]][1], polygone[triangle[1]][2], polygone[triangle[1]][3]), Color(255, mod:get("deathwall_red"), mod:get("deathwall_green"), mod:get("deathwall_blue")))
    end 
end

mod.highlight_dw = function (self)
    local world = Managers.world:world("level_world")
    if not mod.gui then
        local gui = World.create_world_gui(world, Matrix4x4.identity(), 1, 1)
        mod.gui = gui
        local level_settings = LevelHelper:current_level_settings(world)
        local level_path = level_settings.level_name
        local num_nested_levels = LevelResource.nested_level_count(level_path)
        if num_nested_levels > 0 then
            level_path = LevelResource.nested_level_resource_name(level_path, 0)
        end
        local file_path = level_path .. "_nav_tag_volumes"
        local self_mappings = {}
        
        local color_deathwall = Color(mod:get("deathwall_alpha"), mod:get("deathwall_red"), mod:get("deathwall_green"), mod:get("deathwall_blue")) or Color(255, 255, 255, 255)
        
        if Application.can_get("lua", file_path) then
            local mappings = require(file_path)
            self_mappings = table.clone(mappings.nav_tag_volumes)
            
            for level_volume_name, tag_volume_data in pairs(self_mappings) do
                if tag_volume_data.layer_name == "undefined" and (string.find(level_volume_name, "DZ") or string.find(level_volume_name, "dz")) and not string.find(level_volume_name, "skaven") then
                    local value = tag_volume_data.bottom_points
                    counts = #value
                    
                    -- Triangles
                    local polygone = {}
                    for i = 1, counts, 1 do
                        polygone[i] = {value[i][1], value[i][2], tag_volume_data.alt_min}
                    end
                    draw_polygon(polygone) -- Bottom
                    for i = 1, counts, 1 do
                        polygone[i] = {value[i][1], value[i][2], tag_volume_data.alt_max}
                    end
                    draw_polygon(polygone) -- Top
                    
                    for i = 1, counts, 1 do
                        polygone[i] = nil
                    end
                    for i = 1, counts, 1 do
                        if i == counts then
                            polygone[1] = {value[i][1], value[i][2], tag_volume_data.alt_min}
                            polygone[2] = {value[i][1], value[i][2], tag_volume_data.alt_max}
                            polygone[3] = {value[1][1], value[1][2], tag_volume_data.alt_max}
                            polygone[4] = {value[1][1], value[1][2], tag_volume_data.alt_min}
                        else
                            polygone[1] = {value[i][1], value[i][2], tag_volume_data.alt_min}
                            polygone[2] = {value[i][1], value[i][2], tag_volume_data.alt_max}
                            polygone[3] = {value[i + 1][1], value[i + 1][2], tag_volume_data.alt_max}
                            polygone[4] = {value[i + 1][1], value[i + 1][2], tag_volume_data.alt_min}
                        end
                        draw_polygon(polygone) -- Sides
                    end
                end
            end
        end

    end
end

mod.remove_highlights = function (self)
    QuickDrawer:reset()
    QuickDrawerStay:reset()
    if mod.gui then
        local world = Managers.world:world("level_world")
        World.destroy_gui(world, mod.gui)
        mod.gui = nil
    end
end

-- USER FUNCTIONS --
--------------------

-----------
-- HOOKS --



-- HOOKS --
-----------
