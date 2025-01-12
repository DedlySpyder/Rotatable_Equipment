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

local allTech = {} -- Mapping of recipes to list of technology names that unlock it -- recipe -> list of techs
for _, tech in pairs(data.raw["technology"]) do
	if tech.effects then
		for _, effect in ipairs(tech.effects) do
			if effect.type == "unlock-recipe" then
				local recipe = effect.recipe
				if not allTech[recipe] then
					allTech[recipe] = {}
				end
				table.insert(allTech[recipe], tech.name)
			end
		end
	end
end


-- Find each item that places an equipment and create a new one if needed
local newPrototypes = {}

-- Item Groups
table.insert(newPrototypes, {
	type = "item-group",
	name = "RoEq_alt_rotated_equipment",
	order = "zzz",
	icon = "__Rotatable_Equipment__/graphics/item_group.png",
	icon_size = 128,
	hidden = true,
	hidden_in_factoriopedia = true
})

table.insert(newPrototypes, {
	type = "item-subgroup",
	name = "RoEq_alt_rotated_equipment",
	group = "RoEq_alt_rotated_equipment"
})

-- Equipment
function flip_equipment(rawEquipment)
	local shape = rawEquipment.shape
	if not shape then return end
	if shape.height == shape.width then return end
	
	local equipment = table.deepcopy(rawEquipment)
	equipment.name = PROTOTYPE_PREFIX .. rawEquipment.name
	equipment.localised_name = {"RoEq_alt_rotated_prefix", {"equipment-name." .. rawEquipment.name}}
	equipment.localised_description = {"item-description." .. rawEquipment.name}
	
	equipment.shape.height = shape.width
	equipment.shape.width = shape.height

	equipment.sprite = handleSprites(equipment, equipment.sprite, rawEquipment.sprite)

	return equipment
end

function handleSprites(equipment, sprite, originalSprite)

	local skip_overrides = equipment["expected_base_filename"] and
			equipment["expected_base_filename"] ~= sprite["filename"]

	if not skip_overrides and equipment["rotated_sprite"] then
		debugLog("Found rotated sprite")
		return equipment["rotated_sprite"]

	elseif not skip_overrides and equipment["rotated_sprite_filename"] then
		debugLog("Found rotated sprite filename")
		sprite.height = originalSprite.width
		sprite.width = originalSprite.height
		sprite.filename = equipment["rotated_sprite_filename"]

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
	item.localised_name = {"RoEq_alt_rotated_prefix", {"equipment-name." .. oldItem.name}}
	item.place_as_equipment_result = equipment.name
	item.icons = create_icons({oldItem}, true)
	item.hidden = true
	item.hidden_in_factoriopedia = true
	return item
end

function should_show_recipes()
	if mods["equipment-gantry"] then
		return false
	end
	return true
end

function add_recipe_to_techs(oldRecipeName, newRecipeName)
	local techs = allTech[oldRecipeName]
	for _, t in ipairs(techs) do
		table.insert(data.raw["technology"][t].effects, {
			type = "unlock-recipe",
			recipe = newRecipeName,
			hidden = true
		})
	end
end

-- isRotate - true for "_rotate", false for "_restore"
function get_icon_file_name(isRotate)
	if isRotate then
		return "__Rotatable_Equipment__/graphics/rotate_symbol.png"
	else
		return "__Rotatable_Equipment__/graphics/restore_symbol.png"
	end
end

function create_icons(oldPrototypes, isRotate)
	local icons = {}
	for _, oldP in ipairs(oldPrototypes) do
		if oldP.icons then
			icons = table.deepcopy(oldP.icons)
		elseif oldP.icon then
			table.insert(icons, {
				icon = oldP.icon,
				icon_size = oldP.icon_size
			})
		end
		if #icons > 0 then
			break
		end
	end
	table.insert(icons, {
		icon = get_icon_file_name(isRotate),
		icon_size = 64
	})
	return icons
end

function get_recipe_vars(oldName, rotatedName, isRotate)
	if isRotate then
		return "rotate", "az", oldName, rotatedName
	else
		return "restore", "zz", rotatedName, oldName
	end
end

function create_rotational_recipe(oldItem, isRotate, hidden)
	local oldName = oldItem.name
	local oldRecipe = data.raw["recipe"][oldName]
	local recipe = table.deepcopy(oldRecipe)
	local rotatedName = PROTOTYPE_PREFIX .. oldName
	local rotateType, order, ingredientName, resultName = get_recipe_vars(oldName, rotatedName, isRotate)
	if recipe then
		recipe.name = rotatedName .. "_" .. rotateType
		recipe.localised_name = {"RoEq_alt_recipe_" .. rotateType, {"equipment-name." .. oldName}}
		recipe.order = oldItem.order .. order
		recipe.category = "advanced-crafting"
		recipe.subgroup = "RoEq_alt_rotated_equipment"
		recipe.energy_required = 0.5
		recipe.hide_from_player_crafting = true
		recipe.hidden = hidden
		recipe.hidden_in_factoriopedia = true
		recipe.ingredients = {
			{type="item", name=ingredientName, amount=1}
		}
		recipe.results = {
			{type="item", name=resultName, amount=1, ignored_by_stats=1}
		}
		recipe.icons = create_icons({oldRecipe, oldItem}, isRotate)
		add_recipe_to_techs(oldName, recipe.name)
	end
	return recipe
end

function create_alt_equipment(item)
	local rawEquipment = allEquipment[item.place_as_equipment_result]
	if rawEquipment then
		debugLog("Found equipment for " .. item.name)
		local newEquipment = flip_equipment(rawEquipment)
		if not newEquipment then return end

		local newItem = new_item_for_equipment(item, newEquipment)
		debugLog("Creating alternative equipment for " .. item.name)
		table.insert(newPrototypes, newEquipment)
		table.insert(newPrototypes, newItem)
		table.insert(newPrototypes, create_rotational_recipe(item, true, should_show_recipes()))
		table.insert(newPrototypes, create_rotational_recipe(item, false, should_show_recipes()))
	end
end

for _, item in pairs(data.raw["item"]) do
	if item.place_as_equipment_result then
		create_alt_equipment(item)
	end
end

data:extend(newPrototypes)
