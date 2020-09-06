local DEBUG_MODE = true

local debugLog = nil
if DEBUG_MODE then
	debugLog = log
end

function add_sprite_file_name(category, name, filename)
	if data.raw[category] and data.raw[category][name] then
		debugLog("Adding sprite filename <" .. filename .. "> for " .. category .. " - " .. name)
		data.raw[category][name].rotated_sprite_filename = filename
	else
		debugLog("Could not find equipment " .. category .. " - " .. name)
	end
end

add_sprite_file_name("battery-equipment", "battery-equipment", "__Rotatable_Equipment__/graphics/rotated-battery-equipment.png")
add_sprite_file_name("battery-equipment", "battery-mk2-equipment", "__Rotatable_Equipment__/graphics/rotated-battery-mk2-equipment.png")
add_sprite_file_name("movement-bonus-equipment", "exoskeleton-equipment", "__Rotatable_Equipment__/graphics/rotated-exoskeleton-equipment.png")


data:extend({
	{
		name = "RoEq_rotate_equipment",
		type = "custom-input",
		key_sequence = "R"
	}
})
