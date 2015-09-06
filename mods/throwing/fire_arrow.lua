minetest.register_craftitem("throwing:arrow_fire", {
	description = "Fire Arrow",
	inventory_image = "throwing_arrow_fire.png",
})

minetest.register_node("throwing:arrow_fire_box", {
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			-- Shaft
			{-6.5/17, -1.5/17, -1.5/17, 6.5/17, 1.5/17, 1.5/17},
			--Spitze
			{-4.5/17, 2.5/17, 2.5/17, -3.5/17, -2.5/17, -2.5/17},
			{-8.5/17, 0.5/17, 0.5/17, -6.5/17, -0.5/17, -0.5/17},
			--Federn
			{6.5/17, 1.5/17, 1.5/17, 7.5/17, 2.5/17, 2.5/17},
			{7.5/17, -2.5/17, 2.5/17, 6.5/17, -1.5/17, 1.5/17},
			{7.5/17, 2.5/17, -2.5/17, 6.5/17, 1.5/17, -1.5/17},
			{6.5/17, -1.5/17, -1.5/17, 7.5/17, -2.5/17, -2.5/17},

			{7.5/17, 2.5/17, 2.5/17, 8.5/17, 3.5/17, 3.5/17},
			{8.5/17, -3.5/17, 3.5/17, 7.5/17, -2.5/17, 2.5/17},
			{8.5/17, 3.5/17, -3.5/17, 7.5/17, 2.5/17, -2.5/17},
			{7.5/17, -2.5/17, -2.5/17, 8.5/17, -3.5/17, -3.5/17},
		}
	},
	tiles = {"throwing_arrow_fire.png", "throwing_arrow_fire.png", "throwing_arrow_fire_back.png", "throwing_arrow_fire_front.png", "throwing_arrow_fire_2.png", "throwing_arrow_fire.png"},
	groups = {not_in_creative_inventory=1},
})

local THROWING_ARROW_ENTITY={
	physical = false,
	timer=0,
	visual = "wielditem",
	visual_size = {x=0.1, y=0.1},
	textures = {"throwing:arrow_fire_box"},
	lastpos={},
	player = "",
	collisionbox = {0,0,0,0,0,0},
}

THROWING_ARROW_ENTITY.on_step = function(self, dtime)
	local newpos = self.object:getpos()
	if self.lastpos.x ~= nil then
		for _, pos in pairs(throwing_get_trajectoire(self, newpos)) do
			local node = minetest.get_node(pos)
			local objs = minetest.get_objects_inside_radius({x=pos.x,y=pos.y,z=pos.z}, 2)
			for k, obj in pairs(objs) do
				local objpos = obj:getpos()
				if throwing_is_player(self.player, obj) or throwing_is_entity(obj) then
					if (pos.x - objpos.x < 0.5 and pos.x - objpos.x > -0.5) and (pos.z - objpos.z < 0.5 and pos.z - objpos.z > -0.5) then
						local damage = 0
						if minetest.setting_getbool("enable_pvp") then
							damage = 3
						end
						obj:punch(self.object, 1.0, {
								full_punch_interval=1.0,
								damage_groups={fleshy=damage},
								}, nil)
						self.object:remove()
						return
					end
				end
			end
			if node.name ~= "air" and node.name ~= "throwing:light" and node.name ~= "fire:basic_flame" then
				minetest.set_node(self.lastpos, {name="fire:basic_flame"})
				self.object:remove()
				return
			end
			if minetest.get_node(pos).name == "air" then
				minetest.set_node(pos, {name="throwing:light"})
			end
			if minetest.get_node(self.lastpos).name == "throwing:light" then
				minetest.remove_node(self.lastpos)
			end
			self.lastpos={x=pos.x, y=pos.y, z=pos.z}
		end
	end
	self.lastpos={x=newpos.x, y=newpos.y, z=newpos.z}
end


minetest.register_entity("throwing:arrow_fire_entity", THROWING_ARROW_ENTITY)

minetest.register_node("throwing:light", {
	drawtype = "airlike",
	paramtype = "light",
	sunlight_propagates = true,
	tiles = {"throwing_empty.png"},
	light_source = LIGHT_MAX-4,
	selection_box = {
		type = "fixed",
		fixed = {
			{0,0,0,0,0,0}
		}
	},
	groups = {not_in_creative_inventory=1}
})

minetest.register_abm({
	nodenames = {"throwing:light"},
	interval = 10,
	chance = 1,
	action = function(pos, node)
		minetest.remove_node(pos)
	end
})
