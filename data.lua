local DEBUG_MODE = true

local debugLog = nil
if DEBUG_MODE then
	debugLog = log
end

function add_sprite_file_name(category, name, filename, expectedBaseFilename)
	if data.raw[category] and data.raw[category][name] then
		debugLog("Adding sprite filename <" .. filename .. "> for " .. category .. " - " .. name)
		data.raw[category][name].rotated_sprite_filename = filename
		data.raw[category][name].expected_base_filename = expectedBaseFilename
	else
		debugLog("Could not find equipment " .. category .. " - " .. name)
	end
end

function add_hr_sprite_file_name(category, name, filename, expectedBaseFilename)
	if data.raw[category] and data.raw[category][name] then
		debugLog("Adding hr sprite filename <" .. filename .. "> for " .. category .. " - " .. name)
		data.raw[category][name].hr_rotated_sprite_filename = filename
		data.raw[category][name].hr_expected_base_filename = expectedBaseFilename
	else
		debugLog("Could not find equipment " .. category .. " - " .. name)
	end
end

-- Add Normal Sprites
add_sprite_file_name(
		"battery-equipment",
		"battery-equipment",
		"__Rotatable_Equipment__/graphics/rotated-battery-equipment.png",
		"__base__/graphics/equipment/battery-equipment.png"
)

add_sprite_file_name(
		"battery-equipment",
		"battery-mk2-equipment",
		"__Rotatable_Equipment__/graphics/rotated-battery-mk2-equipment.png",
		"__base__/graphics/equipment/battery-mk2-equipment.png"
)

add_sprite_file_name(
		"movement-bonus-equipment",
		"exoskeleton-equipment",
		"__Rotatable_Equipment__/graphics/rotated-exoskeleton-equipment.png",
		"__base__/graphics/equipment/exoskeleton-equipment.png"
)

-- Add HR Sprites
add_hr_sprite_file_name(
		"battery-equipment",
		"battery-equipment",
		"__Rotatable_Equipment__/graphics/rotated-hr-battery-equipment.png",
		"__base__/graphics/equipment/hr-battery-equipment.png"
)

add_hr_sprite_file_name(
		"battery-equipment",
		"battery-mk2-equipment",
		"__Rotatable_Equipment__/graphics/rotated-hr-battery-mk2-equipment.png",
		"__base__/graphics/equipment/hr-battery-mk2-equipment.png"
)

add_hr_sprite_file_name(
		"movement-bonus-equipment",
		"exoskeleton-equipment",
		"__Rotatable_Equipment__/graphics/rotated-hr-exoskeleton-equipment.png",
		"__base__/graphics/equipment/hr-exoskeleton-equipment.png"
)


data:extend({
	{
		name = "RoEq_rotate_equipment",
		type = "custom-input",
		key_sequence = "R"
	}
})
