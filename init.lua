-- Add prospecting_kit to enable radar view in survival mode

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
	minetest.log(dump(prospector.ores))
	minetest.log(dump(visible_ores))

end)

-- Items

minetest.register_craftitem("prospector:prospecting_lens", {
	description = S("Prospecting lens"),
	inventory_image = "prospector_prospecting_lens.png",
})


minetest.register_craftitem("prospector:prospecting_kit", {
	description = S("Prospecting kit"),
	inventory_image = "map_mapping_kit.png^[combine:16x16:4,4=binoculars_binoculars.png\\^[resize\\:8x8",
	stack_max = 1,
	groups = { flammable = 3 },

	on_use = function(itemstack, user, pointed_thing)
		map.update_hud_flags(user)
		binoculars.update_player_property(user)
		-- TODO actually show visible_ores
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
