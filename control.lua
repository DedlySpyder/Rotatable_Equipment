PROTOTYPE_PREFIX = "RoEq_alt_"

function remove_prefix(str)
	return string.sub(str, #PROTOTYPE_PREFIX + 1)
end

function get_rotated_name(equipment_prototype)
	if equipment_prototype then
		local equipment = equipment_prototype.place_as_equipment_result
		if equipment then
			local shape = equipment.shape
			if not shape then return end
			if shape.height == shape.width then return end

			local name = equipment_prototype.name
			if string.find(name, PROTOTYPE_PREFIX) then
				name = remove_prefix(name)
			else
				name = PROTOTYPE_PREFIX .. name
			end
			return name
		end
	end
end

script.on_event("RoEq_rotate_equipment", function(event)
	local player = game.players[event.player_index]
	if player and player.valid then
		if player.cursor_stack and player.cursor_stack.valid_for_read then
			local cursor = player.cursor_stack
			if cursor.can_set_stack then
				local name = get_rotated_name(cursor.prototype)
				if name then
					cursor.set_stack{name=name, count=cursor.count, quality=cursor.quality.name}
				end
			end
		elseif player.cursor_ghost then
			local ghost = player.cursor_ghost
			local name = get_rotated_name(ghost.name)
			if name then
				player.cursor_ghost = {name=name, quality=ghost.quality.name}
			end
		end
	end
end)


script.on_event(defines.events.on_player_main_inventory_changed, function(event)
	local inventory = game.players[event.player_index].get_main_inventory()
	if inventory and inventory.valid then
		for name, count in pairs(inventory.get_contents()) do
			if string.find(name, PROTOTYPE_PREFIX) then
				inventory.remove(name)
				inventory.insert{name=remove_prefix(name), count=count}
			end
		end
	end
end)
