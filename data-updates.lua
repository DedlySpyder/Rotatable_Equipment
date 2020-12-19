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
	
	local sprite = equipment.sprite
	if equipment.rotated_sprite then
		equipment.sprite = equipment.rotated_sprite
		
	elseif equipment.rotated_sprite_filename then
		sprite.height = rawEquipment.sprite.width
		sprite.width = rawEquipment.sprite.height
		sprite.filename = equipment.rotated_sprite_filename
		
	elseif sprite.layers then
		for _, layer in ipairs(sprite.layers) do
			resizeSprite(layer)
		end
	else
		resizeSprite(sprite)
	end
	
	return equipment
end

function resizeSprite(sprite)
	local size = math.min(sprite.height, sprite.width)
	sprite.height = size
	sprite.width = size
end

function new_item_for_equipment(oldItem, equipment)
	local item = table.deepcopy(oldItem)
	item.name = PROTOTYPE_PREFIX .. oldItem.name
	item.localised_name = {"item-name." .. oldItem.name}
	item.placed_as_equipment_result = equipment.name
	item.flags = {"hidden"}
	return item
end

function create_alt_equipment(item)
	local rawEquipment = allEquipment[item.placed_as_equipment_result]
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
	if item.placed_as_equipment_result then
		create_alt_equipment(item)
	end
end

data:extend(newPrototypes)
