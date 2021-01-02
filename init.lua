-- Prospector mod
-- This mod provides a prospecting kit, that combines the capabilities of the mapping kit
-- and binoculars, enables radar view in the minimap, and can give hints about the location
-- of hidden ores.

-- Load support for MT game translation.
local S = minetest.get_translator("map")

-- Global table to allow other mods to register special nodes
-- the prospector might identify
prospector = {}

-- To specify that a node should NOT be seen by the prospecting kit,
-- add it as key to prospector.ores with a negative value
-- If you want it to be seen by the prospecting kit, add it as key with a nonzero value.
-- By default all registered ores except the ones that map to 0 will be seen
prospector.ores = {
	["default:dirt"] = -1,
	["default:sand"] = -1,
	["default:silver_sand"] = -1,
	["default:gravel"] = -1,
}

-- Internal list for the kit
local visible_ores = {}

minetest.register_on_mods_loaded(function()
	-- override map.update_hud_flags to also check for prospecting kit
	local old_map_update_func = map.update_hud_flags

	function map.update_hud_flags(player)
		local flags = {}
		if player:get_inventory():contains_item("main", "prospector:prospecting_kit") then
			flags.minimap = true
			flags.minimap_radar = true
			player:hud_set_flags(flags)
		else
			old_map_update_func(player)
		end
	end

	-- override binoculars.update_player_property as well
	local old_binoculars_update_func = binoculars.update_player_property

	function binoculars.update_player_property(player)
		if player:get_inventory():contains_item("main", "prospector:prospecting_kit") then
			local new_zoom_fov = 8

			-- Only set property if necessary to avoid player mesh reload
			if player:get_properties().zoom_fov ~= new_zoom_fov then
				player:set_properties({zoom_fov = new_zoom_fov})
			end
		else
			old_binoculars_update_func(player)
		end
	end

	for _, def in pairs(minetest.registered_ores) do
		local name = def.ore
		local wanted = prospector.ores[name] or 0
		if wanted >= 0 then
			prospector.ores[name] = wanted + def.clust_scarcity
		end
	end

	local n = 0
	for k, v in pairs(prospector.ores) do
		if v >= 0 then
			n = n + 1
			visible_ores[n] = k
		end
	end
	--minetest.log(dump(prospector.ores))
	--minetest.log(dump(visible_ores))

end)

local detect_ores = function(player)
	local player_pos = player:get_pos()
	local player_name = player:get_player_name()

	-- adjust player position to eye level, roundeded to integer
	player_pos.y = player_pos.y + 1
	player_pos = vector.round(player_pos)

	local range = 16 -- TODO

	local pos_low = vector.subtract(player_pos, range)
	local pos_hi = vector.add(player_pos, range)

	local nodes_found = minetest.find_nodes_in_area(pos_low, pos_hi, visible_ores, true)
	for _, node_pos in pairs(nodes_found) do
		local node = minetest.get_node(node_pos)
		local name = node.name
		local drop = minetest.registered_nodes[name].drop
		local drop_tex = minetest.registered_items[drop].inventory_image

		--minetest.log( dump({name, drop, dist}) )

		local timescale = 0.3

		local node_dir = vector.subtract(player_pos, node_pos)
		local dist = vector.length(node_dir)

		local scale = 2
		local minscale = dist/timescale
		local maxscale = dist*scale/timescale

		minetest.add_particlespawner({
			player = player_name,
			amount = 4,
			time = timescale,
			minpos = vector.subtract(node_pos, 0.5),
			maxpos = vector.add(node_pos, 0.5),
			minvel = vector.divide(node_dir, minscale),
			maxvel = vector.divide(node_dir, maxscale),
			minacc = vector.new(),
			maxacc = vector.new(),
			minexptime = minscale,
			maxexptime = maxscale,
			texture = drop_tex,
			collision_detection = false,
			minsize = 0.1,
			maxsize = 0.3,
			glow = LIGHT_MAX-1,
		})
	end
end

-- Items

local kit_name = S("Prospecting kit")

minetest.register_craftitem("prospector:prospecting_lens", {
	description = S("Prospecting lens"),
	_doc_items_longdesc = S("A lens giving special detecting capabilities when assembled into a @1.", kit_name),
	_doc_items_usagehelp = S("Combine two lenses with the binculars and mapping kit to obtain a @1.", kit_name),
	inventory_image = "prospector_prospecting_lens.png",
})


minetest.register_craftitem("prospector:prospecting_kit", {
	description = kit_name,
	_doc_items_longdesc = S("Combines and improves the capabilities of the mapping kit and binoculars."),
	_doc_items_usagehelp = S("Keep this in your inventory to enable the minimap and zoom features.") ..
		" " .. S("Use (click) to get an idea of where ores might be around you"),
	inventory_image = "map_mapping_kit.png^[combine:16x16:4,4=binoculars_binoculars.png\\^[resize\\:8x8",
	stack_max = 1,
	groups = { flammable = 3 },

	on_use = function(itemstack, user, pointed_thing)
		map.update_hud_flags(user)
		binoculars.update_player_property(user)
		detect_ores(user)
	end,
})

-- Crafting

minetest.register_craft({
	output = "prospector:prospecting_lens",
	recipe = {
		{"default:gold_ingot", "default:diamond", "default:gold_ingot" },
		{"default:diamond", "default:mese_crystal", "default:diamond" },
		{"default:gold_ingot", "default:diamond", "default:gold_ingot" },
	}
})

minetest.register_craft({
	output = "prospector:prospecting_kit",
	recipe = {
		{"prospector:prospecting_lens", "binoculars:binoculars", "prospector:prospecting_lens" },
		{"", "map:mapping_kit", "" },
	}
})
