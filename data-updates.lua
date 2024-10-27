local DEBUG_MODE = true

local debugLog = nil
if DEBUG_MODE then
	debugLog = log
end


PROTOTYPE_PREFIX = "RoEq_alt_"


-- Flatten the equipment to a single table
local allEquipment = {}

for category, catData in pairs(data.raw) do
	if string.match(category, "equipment") and category ~= "equipment-grid" and category ~= "equipment-category" then
		for name, datum in pairs(catData) do
			debugLog("Equipment category: " .. category .. " - name: " .. name)
			allEquipment[name] = datum
		end
	end
end


-- Find each item that places an equipment and create a new one if needed
local newPrototypes = {}

function flip_equipment(rawEquipment)
	local shape = rawEquipment.shape
	if not shape then return end
	if shape.height == shape.width then return end
	
	local equipment = table.deepcopy(rawEquipment)
	equipment.name = PROTOTYPE_PREFIX .. rawEquipment.name
	equipment.localised_name = {"equipment-name." .. rawEquipment.name}
	equipment.localised_description = {"item-description." .. rawEquipment.name}
	
	equipment.shape.height = shape.width
	equipment.shape.width = shape.height

	equipment.sprite = handleSprites(equipment, equipment.sprite, rawEquipment.sprite)

	if equipment.sprite.hr_version then
		equipment.sprite.hr_version = handleSprites(equipment, equipment.sprite.hr_version, rawEquipment.sprite.hr_version, true)
	end

	return equipment
end

function handleSprites(equipment, sprite, originalSprite, isHr)
	local hrPrefix = ""
	if isHr then hrPrefix = "hr_" end

	local skip_overrides = equipment[hrPrefix .. "expected_base_filename"] and
			equipment[hrPrefix .. "expected_base_filename"] ~= sprite["filename"]

	if not skip_overrides and equipment[hrPrefix .. "rotated_sprite"] then
		debugLog("Found rotated sprite")
		return equipment[hrPrefix .. "rotated_sprite"]

	elseif not skip_overrides and equipment[hrPrefix .. "rotated_sprite_filename"] then
		debugLog("Found rotated sprite filename")
		sprite.height = originalSprite.width
		sprite.width = originalSprite.height
		sprite.filename = equipment[hrPrefix .. "rotated_sprite_filename"]

	elseif sprite.layers then
		debugLog("Defaulting to shrinking layers")
		for _, layer in ipairs(sprite.layers) do
			resizeSprite(layer, equipment.shape)
		end

	else
		debugLog("Defaulting to shrinking")
		resizeSprite(sprite, equipment.shape)
	end

	return sprite
end

function resizeSprite(sprite, shape)
	local h = shape.height
	local w = shape.width
	if h > w then
		sprite.scale = w / h
	else
		sprite.scale = h / w
	end
end

function new_item_for_equipment(oldItem, equipment)
	local item = table.deepcopy(oldItem)
	item.name = PROTOTYPE_PREFIX .. oldItem.name
	item.localised_name = {"item-name." .. oldItem.name}
	item.place_as_equipment_result = equipment.name
	item.hidden = true
	item.hidden_in_factoriopedia = true
	return item
end

function create_alt_equipment(item)
	local rawEquipment = allEquipment[item.place_as_equipment_result]
	if rawEquipment then
		debugLog("Found equipment for " .. item.name)
		local newEquipment = flip_equipment(rawEquipment)
		if not newEquipment then return end
		
		debugLog("Creating alternative equipment for " .. item.name)
		table.insert(newPrototypes, newEquipment)
		table.insert(newPrototypes, new_item_for_equipment(item, newEquipment))
	end
end

for _, item in pairs(data.raw["item"]) do
	if item.place_as_equipment_result then
		create_alt_equipment(item)
	end
end

data:extend(newPrototypes)
