PROTOTYPE_PREFIX = "RoEq_alt_"

function remove_prefix(str)
	return string.sub(str, #PROTOTYPE_PREFIX + 1)
end

script.on_event("RoEq_rotate_equipment", function(event)
	local player = game.players[event.player_index]
	
	if player and player.valid and player.cursor_stack and player.cursor_stack.valid_for_read then
		local cursor = player.cursor_stack
		local equipment = cursor.prototype.place_as_equipment_result
		if equipment and cursor.can_set_stack then
			local shape = equipment.shape
			if not shape then return end
			if shape.height == shape.width then return end
			
			local name = cursor.name
			if string.find(name, PROTOTYPE_PREFIX) then
				name = remove_prefix(name)
			else
				name = PROTOTYPE_PREFIX .. name
			end
			
			log("New equipment: " .. name)
			cursor.set_stack{name=name, count=cursor.count, quality=cursor.quality.name}
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
