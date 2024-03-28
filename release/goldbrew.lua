package = {}
local preload, loaded = {}, {
    string = string,
    debug = debug,
    package = package,
    _G = _G,
    io = io,
    os = os,
    table = table,
    math = math,
    coroutine = coroutine
}
package.preload, package.loaded = preload, loaded

function require(mod)
    if not loaded[mod] then
        local f = preload[mod]
        if f == nil then
            error("module '" .. mod .. [[' not found:
       no field package.preload[']] .. mod .. "']", 1)
        end
        local v = f(mod)
        if v ~= nil then
            loaded[mod] = v
        elseif loaded[mod] == nil then
            loaded[mod] = true
        end
    end
    return loaded[mod]
end
do
local _ENV = _ENV
package.preload[ "auction_data_browser" ] = function( ... ) local arg = _G.arg;
local helpers = require("helpers")

local function get_prices_from_ids(item_ids, database_data) -- Should probably return same number of items, what to do if it doesn't? Meaning some prices are not found?
    local item_ids_with_prices = {}

    for item in database_data:gmatch("i[^i]+") do
        local item_id, item_info = item:match("i([^?!]+)[?!](.+)")
        local buyout_price = item_info:match("[^,]+,[^,]+,([^,]+)")

        if helpers.table_has_value(item_ids, tonumber(item_id)) then
            table.insert(item_ids_with_prices, {
                item_id = item_id,
                buyout_price = buyout_price
            })
        end
    end
    return item_ids_with_prices
end

local function get_auctions_from_raw_data(auction_data, character_name, realm_name)
    local char = character_name .. "-" .. realm_name;
    local data = {};
    for _, characterData in ipairs(auction_data["ah"]) do
        if characterData["char"] == char then
            table.insert(data, characterData["data"]);
        end
    end
    local concatenated_data = table.concat(data, "");

    return concatenated_data
end

return {
    get_prices_from_ids = get_prices_from_ids,
    get_auctions_from_raw_data = get_auctions_from_raw_data
}
end
end

do
local _ENV = _ENV
package.preload[ "available_recipes_finder" ] = function( ... ) local arg = _G.arg;
local function get_available_recipes_from_inventory(inventory, recipes) -- TODO returns itemId instead of item_id because of reagent json converted table, should be cleaned up
    local availableRecipes = {}

    -- Iterate through each recipe
    for _, recipe in ipairs(recipes.allRecipes) do
        local can_craft = true

        -- Check each reagent in the recipe
        for _, reagent in ipairs(recipe.reagents) do
            local item_id = reagent.itemId
            local requiredAmount = reagent.amount

            -- Check if the reagent is present in the inventory and in sufficient quantity
            if not inventory[item_id] or inventory[item_id] < requiredAmount then
                can_craft = false
                break -- No need to check further if one reagent is missing
            end
        end

        -- If all reagents are present, add the recipe to the list of available recipes
        if can_craft then
            table.insert(availableRecipes, recipe)
        end
    end

    return availableRecipes
end

local function get_reagents_from_recipe_id(recipe_id, recipes)
    for _, recipe in ipairs(recipes) do
        if recipe.itemId == recipe_id then
            return recipe.reagents
        end
    end

    return nil
end

return {
    get_available_recipes_from_inventory = get_available_recipes_from_inventory,
    get_reagents_from_recipe_id = get_reagents_from_recipe_id
}
end
end

do
local _ENV = _ENV
package.preload[ "bag_browser" ] = function( ... ) local arg = _G.arg;
local alchemy_material_ids = require("static_data.alchemy_material_ids")

local function get_bag_contents(bag_data)
    local concatenated_bags = {}
    for i = 0, 4 do
        local bag_content = bag_data[i]
        if bag_content then
            for _, item in ipairs(bag_content) do
                table.insert(concatenated_bags, item)
            end
        end
    end
    return concatenated_bags
end
local function get_item_counts_by_ids(item_ids, bags_content)
    local item_amounts_by_id = {}
    for _, str in ipairs(bags_content) do
        local string_id, string_amount = str:match("([^:]+)::::::::.-:::::::::;([^:]+)")
        if string_id and string_amount ~= "" then
            local found_item_id = tonumber(string_id)
            for _, lookup_item_id in ipairs(item_ids) do
                if found_item_id == lookup_item_id then
                    table.insert(item_amounts_by_id, {tonumber(found_item_id), tonumber(string_amount)})
                    break
                end
            end
        end
    end
    local summed_item_amounts_by_id = {}
    for _, entry in ipairs(item_amounts_by_id) do
        local id = tonumber(entry[1])
        local count = tonumber(entry[2])
        if summed_item_amounts_by_id[id] then
            summed_item_amounts_by_id[id] = summed_item_amounts_by_id[id] + count
        else
            summed_item_amounts_by_id[id] = count
        end
    end
    return summed_item_amounts_by_id
end
local function get_all_herbs_from_inventory(bag_contents)
    local formatted_bag_contents = get_bag_contents(bag_contents)
    return get_item_counts_by_ids(alchemy_material_ids, formatted_bag_contents)
end
return {
    get_all_herbs_from_inventory = get_all_herbs_from_inventory,
    get_bag_contents = get_bag_contents,
    get_item_counts_by_ids = get_item_counts_by_ids
}
end
end

do
local _ENV = _ENV
package.preload[ "helpers" ] = function( ... ) local arg = _G.arg;
local function get_item_ids_from_recipes(availableRecipes)
    local itemIds = {}

    for _, recipe in ipairs(availableRecipes) do
        table.insert(itemIds, recipe.itemId)
    end

    return itemIds
end
local function find_price_by_item_id(price_data, target_item_id)
    for _, entry in ipairs(price_data) do
        if tonumber(entry.item_id) == target_item_id then
            return entry.buyout_price
        end
    end
    return 0 -- Or any default value if the item_id is not found
end

local function print_matrix(tableau)
    for i = 1, #tableau do
        local numeric_format = "%.2f";

        if i == 1 then
            numeric_format = "%.0f";
        end
        for j = 1, #tableau[i] do
            if j == 1 then
                numeric_format = "%.0f";
            end
            io.write(string.format(numeric_format, tableau[i][j]))
            if j < #tableau[i] then
                io.write("\t")
            end
        end
        io.write("\n")
    end
end

local function concat_tables(t1, t2)
    for i = 1, #t2 do
        t1[#t1 + 1] = t2[i]
    end
    return t1
end

local function table_length(table)
    local count = 0
    for _ in pairs(table) do
        count = count + 1
    end
    return count
end

local function get_nth_item(table, n)
    local current_index = 1

    for id, number in pairs(table) do
        if current_index == n then
            return id, number
        end

        current_index = current_index + 1
    end

    return nil, nil
end

local function get_herb_ids_from_bag_data(bag_herb_data)
    local herb_ids = {}
    for id, count in pairs(bag_herb_data) do
        table.insert(herb_ids, id)
    end
    return herb_ids
end

local function extract_results_from_solved_matrix(solved_matrix, original_matrix_with_ids)
    local indexes_of_result = {}

    local current_value_index = 1
    for i = 1, #solved_matrix[1] do

        local last_row_index = #solved_matrix;
        local last_row = solved_matrix[last_row_index]
        local value_in_last_row = last_row[i];
        if value_in_last_row == 0 then
            local item_id = original_matrix_with_ids[1][i + 1]

            local amount = solved_matrix[current_value_index][#solved_matrix[1]]
            table.insert(indexes_of_result, {item_id, amount})
            current_value_index = current_value_index + 1
        end
    end
    return indexes_of_result
end

local function simple_assert(a, b)
    if a ~= b then
        print("Values are not matching, test failed")
        return
    end
end

local function table_has_value(table_to_browse, value_to_find)
    for _, value in ipairs(table_to_browse) do
        if value == value_to_find then
            return true
        end
    end

    return false
end

return {
    get_item_ids_from_recipes = get_item_ids_from_recipes,
    concat_tables = concat_tables,
    print_matrix = print_matrix,
    table_length = table_length,
    get_nth_item = get_nth_item,
    find_price_by_item_id = find_price_by_item_id,
    extract_results_from_solved_matrix = extract_results_from_solved_matrix,
    simple_assert = simple_assert,
    get_herb_ids_from_bag_data = get_herb_ids_from_bag_data,
    table_has_value = table_has_value
}
end
end

do
local _ENV = _ENV
package.preload[ "simplex_calculator.core" ] = function( ... ) local arg = _G.arg;
local helpers = require("helpers")

local function get_pivot_column_index(tableau)
    local lowest_value = math.huge
    local lowest_index = -1

    for i = 1, #tableau[1] - 1 do
        if tableau[#tableau][i] < lowest_value then
            lowest_value = tableau[#tableau][i]
            lowest_index = i
        end
    end

    return lowest_index
end

local function get_pivot_row_index(tableau, column_index)
    local lowest_ratio = math.huge
    local lowest_index = -1

    for i = 1, #tableau - 1 do
        if tableau[i][column_index] > 0 then
            local ratio = tableau[i][#tableau[1]] / tableau[i][column_index]
            if ratio < lowest_ratio then
                lowest_ratio = ratio
                lowest_index = i
            end
        end
    end

    return lowest_index
end

local function pick_pivot(tableau)
    local column_index = get_pivot_column_index(tableau)
    local row_index = get_pivot_row_index(tableau, column_index)
    return column_index, row_index
end

local function get_pivot_to_one(tableau, pivot_row_index, pivot_column_index)
    local pivot_value = tableau[pivot_row_index][pivot_column_index]
    for i = 1, #tableau[1] do
        tableau[pivot_row_index][i] = tableau[pivot_row_index][i] / pivot_value
    end
end

local function get_zeroes_in_all_rows_except_pivot(tableau, pivot_row_index, pivot_column_index)
    for i = 1, #tableau do
        if i ~= pivot_row_index then
            local ratio_to_clear_row = -tableau[i][pivot_column_index]
            for j = 1, #tableau[1] do
                tableau[i][j] = tableau[i][j] + (tableau[pivot_row_index][j] * ratio_to_clear_row)
            end
        end
    end
end

local function has_negative_value_in_last_row(matrix)
    local last_row = matrix[#matrix]
    for i = 1, #last_row - 1 do
        if last_row[i] < 0 then
            return true
        end
    end
    return false
end

local function solve_simplex_task(tableau)
    while has_negative_value_in_last_row(tableau) do
        local column_index, row_index = pick_pivot(tableau)
        get_pivot_to_one(tableau, row_index, column_index)
        get_zeroes_in_all_rows_except_pivot(tableau, row_index, column_index)
    end
end

return {
    solve_simplex_task = solve_simplex_task
}
end
end

do
local _ENV = _ENV
package.preload[ "simplex_generator" ] = function( ... ) local arg = _G.arg;
local helpers = require("helpers")
local available_recipes_finder = require("available_recipes_finder")

local function construct_simplex_matrix_from_data(bag_data, available_recipes, price_data)

    local bag_data_length = helpers.table_length(bag_data);
    local available_recipes_length = helpers.table_length(available_recipes);

    local row_count = bag_data_length + 2;
    local column_count = bag_data_length + available_recipes_length + 2;

    local simplex_matrix = {}
    for i = 1, row_count do
        simplex_matrix[i] = {}
        for j = 1, column_count do
            simplex_matrix[i][j] = 0
        end
    end

    for i = 1, column_count do
        for j = 1, row_count do
            local recipe_id

            if (i < available_recipes_length + 1) then
                recipe_id = available_recipes[i].itemId
            else
                local id, amount = helpers.get_nth_item(bag_data, i - available_recipes_length)
                recipe_id = id
            end

            simplex_matrix[1][i + 1] = recipe_id;

            local id, amount = helpers.get_nth_item(bag_data, j)
            if (i == 1) then
                if id ~= nil then
                    simplex_matrix[j + 1][1] = id
                end
            end

            if (i == column_count) then
                if amount ~= nil then
                    simplex_matrix[j + 1][column_count] = amount
                end
            end

            if j == row_count then
                simplex_matrix[row_count][i + 1] = -helpers.find_price_by_item_id(price_data, recipe_id)
            end
        end
    end

    for i = 1, column_count do
        local recipe_id

        if (i < available_recipes_length + 1) then
            recipe_id = available_recipes[i].itemId
        else
            local id, amount = helpers.get_nth_item(bag_data, i - available_recipes_length)
            recipe_id = id
        end

        local reagents = available_recipes_finder.get_reagents_from_recipe_id(recipe_id, available_recipes);
        if reagents == nil then
            for t = 1, row_count do
                if simplex_matrix[t][1] == recipe_id then
                    simplex_matrix[t][i + 1] = 1
                end
            end
        else
            for r = 1, #reagents do
                for t = 1, row_count do
                    if simplex_matrix[t][1] == reagents[r].itemId then
                        simplex_matrix[t][i + 1] = reagents[r].amount
                    end
                end
            end
        end

    end

    return simplex_matrix

end

local function strip_tag_data_from_matrix(matrix)
  local stripped_matrix = {}

  -- Iterate over rows starting from the second row
  for i = 2, #matrix do
      stripped_matrix[i - 1] = {}

      -- Iterate over columns starting from the second column
      for j = 2, #matrix[i] do
          stripped_matrix[i - 1][j - 1] = matrix[i][j]
      end
  end

  return stripped_matrix
end

return {
    construct_simplex_matrix_from_data = construct_simplex_matrix_from_data,
    strip_tag_data_from_matrix = strip_tag_data_from_matrix
}
end
end

do
local _ENV = _ENV
package.preload[ "static_data.alchemy_material_ids" ] = function( ... ) local arg = _G.arg;
return { -- Item ids and names
765, -- Silverleaf
785, -- Mageroyal
2447, -- Peacebloom
2449, -- Earthroot
2450, -- Briarthorn
2452, -- Swiftthistle
2453, -- Bruiseweed
3355, -- Wild Steelbloom
3356, -- Kingsblood
3357, -- Liferoot
3358, -- Khadgar's Whisker
3369, -- Grave Moss
3818, -- Fadeleaf
3819, -- Wintersbite
3820, -- Stranglekelp
3821, -- Goldthorn
4625, -- Firebloom
7067, -- Elemental Earth
7068, -- Elemental Fire
7070, -- Elemental Water
8153, -- Wildvine
8831, -- Purple Lotus
8836, -- Arthas' Tears
8838, -- Sungrass
8839, -- Blindweed
8845, -- Ghost Mushroom
8846, -- Gromsblood
13463, -- Dreamfoil
13464, -- Golden Sansam
13465, -- Mountain Silversage
13466, -- Plaguebloom
13467, -- Icecap
13468, -- Black Lotus
19726 -- Bloodvine
}
end
end

do
local _ENV = _ENV
package.preload[ "static_data.alchemy_recipes" ] = function( ... ) local arg = _G.arg;
return {
    allRecipes = {{
        name = "Minor Healing Potion",
        itemId = 118,
        reagents = {{
            itemId = 2447,
            amount = 1
        }, {
            itemId = 765,
            amount = 1
        }}
    }, {
        name = "Lesser Healing Potion",
        itemId = 858,
        reagents = {{
            itemId = 118,
            amount = 1
        }, {
            itemId = 2450,
            amount = 1
        }}
    }, {
        name = "Healing Potion",
        itemId = 929,
        reagents = {{
            itemId = 2453,
            amount = 1
        }, {
            itemId = 2450,
            amount = 1
        }}
    }, {
        name = "Greater Healing Potion",
        itemId = 1710,
        reagents = {{
            itemId = 3357,
            amount = 1
        }, {
            itemId = 3356,
            amount = 1
        }}
    }, {
        name = "Elixir of Lion's Strength",
        itemId = 2454,
        reagents = {{
            itemId = 2449,
            amount = 1
        }, {
            itemId = 765,
            amount = 1
        }}
    }, {
        name = "Elixir of Minor Agility",
        itemId = 2457,
        reagents = {{
            itemId = 2452,
            amount = 1
        }, {
            itemId = 765,
            amount = 1
        }}
    }, {
        name = "Minor Mana Potion",
        itemId = 2455,
        reagents = {{
            itemId = 785,
            amount = 1
        }, {
            itemId = 765,
            amount = 1
        }}
    }, {
        name = "Elixir of Minor Fortitude",
        itemId = 2458,
        reagents = {{
            itemId = 2449,
            amount = 2
        }, {
            itemId = 2447,
            amount = 1
        }}
    }, {
        name = "Minor Rejuvenation Potion",
        itemId = 2456,
        reagents = {{
            itemId = 785,
            amount = 2
        }, {
            itemId = 2447,
            amount = 1
        }}
    }, {
        name = "Swiftness Potion",
        itemId = 2459,
        reagents = {{
            itemId = 2452,
            amount = 1
        }, {
            itemId = 2450,
            amount = 1
        }}
    }, {
        name = "Weak Troll's Blood Elixir",
        itemId = 3382,
        reagents = {{
            itemId = 2447,
            amount = 1
        }, {
            itemId = 2449,
            amount = 2
        }}
    }, {
        name = "Minor Magic Resistance Potion",
        itemId = 3384,
        reagents = {{
            itemId = 785,
            amount = 3
        }, {
            itemId = 3355,
            amount = 1
        }}
    }, {
        name = "Lesser Mana Potion",
        itemId = 3385,
        reagents = {{
            itemId = 785,
            amount = 1
        }, {
            itemId = 3820,
            amount = 1
        }}
    }, {
        name = "Elixir of Wisdom",
        itemId = 3383,
        reagents = {{
            itemId = 785,
            amount = 1
        }, {
            itemId = 2450,
            amount = 2
        }}
    }, {
        name = "Limited Invulnerability Potion",
        itemId = 3387,
        reagents = {{
            itemId = 8839,
            amount = 2
        }, {
            itemId = 8845,
            amount = 1
        }}
    }, {
        name = "Strong Troll's Blood Elixir",
        itemId = 3388,
        reagents = {{
            itemId = 2453,
            amount = 2
        }, {
            itemId = 2450,
            amount = 2
        }}
    }, {
        name = "Elixir of Lesser Agility",
        itemId = 3390,
        reagents = {{
            itemId = 3355,
            amount = 1
        }, {
            itemId = 2452,
            amount = 1
        }}
    }, {
        name = "Elixir of Defense",
        itemId = 3389,
        reagents = {{
            itemId = 3355,
            amount = 1
        }, {
            itemId = 3820,
            amount = 1
        }}
    }, {
        name = "Elixir of Ogre's Strength",
        itemId = 3391,
        reagents = {{
            itemId = 2449,
            amount = 1
        }, {
            itemId = 3356,
            amount = 1
        }}
    }, {
        name = "Shadow Oil",
        itemId = 3824,
        reagents = {{
            itemId = 3818,
            amount = 4
        }, {
            itemId = 3369,
            amount = 4
        }}
    }, {
        name = "Lesser Invisibility Potion",
        itemId = 3823,
        reagents = {{
            itemId = 3818,
            amount = 1
        }, {
            itemId = 3355,
            amount = 1
        }}
    }, {
        name = "Elixir of Fortitude",
        itemId = 3825,
        reagents = {{
            itemId = 3355,
            amount = 1
        }, {
            itemId = 3821,
            amount = 1
        }}
    }, {
        name = "Major Troll's Blood Elixir",
        itemId = 3826,
        reagents = {{
            itemId = 3357,
            amount = 1
        }, {
            itemId = 2453,
            amount = 1
        }}
    }, {
        name = "Mana Potion",
        itemId = 3827,
        reagents = {{
            itemId = 3820,
            amount = 1
        }, {
            itemId = 3356,
            amount = 1
        }}
    }, {
        name = "Frost Oil",
        itemId = 3829,
        reagents = {{
            itemId = 3358,
            amount = 4
        }, {
            itemId = 3819,
            amount = 2
        }}
    }, {
        name = "Elixir of Detect Lesser Invisibility",
        itemId = 3828,
        reagents = {{
            itemId = 3358,
            amount = 1
        }, {
            itemId = 3818,
            amount = 1
        }}
    }, {
        name = "Superior Healing Potion",
        itemId = 3928,
        reagents = {{
            itemId = 8838,
            amount = 1
        }, {
            itemId = 3358,
            amount = 1
        }}
    }, {
        name = "Discolored Healing Potion",
        itemId = 4596,
        reagents = {{
            itemId = 3164,
            amount = 1
        }, {
            itemId = 2447,
            amount = 1
        }}
    }, {
        name = "Lesser Stoneshield Potion",
        itemId = 4623,
        reagents = {{
            itemId = 3858,
            amount = 1
        }, {
            itemId = 3821,
            amount = 1
        }}
    }, {
        name = "Great Rage Potion",
        itemId = 5633,
        reagents = {{
            itemId = 5637,
            amount = 1
        }, {
            itemId = 3356,
            amount = 1
        }}
    }, {
        name = "Free Action Potion",
        itemId = 5634,
        reagents = {{
            itemId = 6370,
            amount = 2
        }, {
            itemId = 3820,
            amount = 1
        }}
    }, {
        name = "Rage Potion",
        itemId = 5631,
        reagents = {{
            itemId = 5635,
            amount = 2
        }}
    }, {
        name = "Elixir of Water Breathing",
        itemId = 5996,
        reagents = {{
            itemId = 3820,
            amount = 1
        }, {
            itemId = 6370,
            amount = 2
        }}
    }, {
        name = "Elixir of Minor Defense",
        itemId = 5997,
        reagents = {{
            itemId = 765,
            amount = 2
        }}
    }, {
        name = "Shadow Protection Potion",
        itemId = 6048,
        reagents = {{
            itemId = 3369,
            amount = 1
        }, {
            itemId = 3356,
            amount = 1
        }}
    }, {
        name = "Frost Protection Potion",
        itemId = 6050,
        reagents = {{
            itemId = 3819,
            amount = 1
        }, {
            itemId = 3821,
            amount = 1
        }}
    }, {
        name = "Holy Protection Potion",
        itemId = 6051,
        reagents = {{
            itemId = 2453,
            amount = 1
        }, {
            itemId = 2452,
            amount = 1
        }}
    }, {
        name = "Nature Protection Potion",
        itemId = 6052,
        reagents = {{
            itemId = 3357,
            amount = 1
        }, {
            itemId = 3820,
            amount = 1
        }}
    }, {
        name = "Fire Protection Potion",
        itemId = 6049,
        reagents = {{
            itemId = 4402,
            amount = 1
        }, {
            itemId = 6371,
            amount = 1
        }}
    }, {
        name = "Greater Mana Potion",
        itemId = 6149,
        reagents = {{
            itemId = 3358,
            amount = 1
        }, {
            itemId = 3821,
            amount = 1
        }}
    }, {
        name = "Swim Speed Potion",
        itemId = 6372,
        reagents = {{
            itemId = 2452,
            amount = 1
        }, {
            itemId = 6370,
            amount = 1
        }}
    }, {
        name = "Blackmouth Oil",
        itemId = 6370,
        reagents = {{
            itemId = 6358,
            amount = 2
        }}
    }, {
        name = "Fire Oil",
        itemId = 6371,
        reagents = {{
            itemId = 6359,
            amount = 2
        }}
    }, {
        name = "Elixir of Giant Growth",
        itemId = 6662,
        reagents = {{
            itemId = 6522,
            amount = 1
        }, {
            itemId = 2449,
            amount = 1
        }}
    }, {
        name = "Elemental Fire",
        itemId = 7068,
        reagents = {{
            itemId = 7077,
            amount = 1
        }}
    }, {
        name = "Essence of Fire",
        itemId = 7078,
        reagents = {{
            itemId = 7082,
            amount = 1
        }}
    }, {
        name = "Essence of Earth",
        itemId = 7076,
        reagents = {{
            itemId = 7078,
            amount = 1
        }}
    }, {
        name = "Essence of Water",
        itemId = 7080,
        reagents = {{
            itemId = 7076,
            amount = 1
        }}
    }, {
        name = "Essence of Air",
        itemId = 7082,
        reagents = {{
            itemId = 7080,
            amount = 1
        }}
    }, {
        name = "Elixir of Agility",
        itemId = 8949,
        reagents = {{
            itemId = 3820,
            amount = 1
        }, {
            itemId = 3821,
            amount = 1
        }}
    }, {
        name = "Oil of Immolation",
        itemId = 8956,
        reagents = {{
            itemId = 4625,
            amount = 1
        }, {
            itemId = 3821,
            amount = 1
        }}
    }, {
        name = "Elixir of Greater Defense",
        itemId = 8951,
        reagents = {{
            itemId = 3355,
            amount = 1
        }, {
            itemId = 3821,
            amount = 1
        }}
    }, {
        name = "Magic Resistance Potion",
        itemId = 9036,
        reagents = {{
            itemId = 3358,
            amount = 1
        }, {
            itemId = 8831,
            amount = 1
        }}
    }, {
        name = "Gift of Arthas",
        itemId = 9088,
        reagents = {{
            itemId = 8836,
            amount = 1
        }, {
            itemId = 8839,
            amount = 1
        }}
    }, {
        name = "Restorative Potion",
        itemId = 9030,
        reagents = {{
            itemId = 7067,
            amount = 1
        }, {
            itemId = 3821,
            amount = 1
        }}
    }, {
        name = "Goblin Rocket Fuel",
        itemId = 9061,
        reagents = {{
            itemId = 4625,
            amount = 1
        }, {
            itemId = 9260,
            amount = 1
        }}
    }, {
        name = "Wildvine Potion",
        itemId = 9144,
        reagents = {{
            itemId = 8153,
            amount = 1
        }, {
            itemId = 8831,
            amount = 1
        }}
    }, {
        name = "Elixir of Detect Undead",
        itemId = 9154,
        reagents = {{
            itemId = 8836,
            amount = 1
        }}
    }, {
        name = "Philosopher's Stone",
        itemId = 9149,
        reagents = {{
            itemId = 3575,
            amount = 4
        }, {
            itemId = 9262,
            amount = 1
        }, {
            itemId = 8831,
            amount = 4
        }, {
            itemId = 4625,
            amount = 4
        }}
    }, {
        name = "Elixir of Giants",
        itemId = 9206,
        reagents = {{
            itemId = 8838,
            amount = 1
        }, {
            itemId = 8846,
            amount = 1
        }}
    }, {
        name = "Arcane Elixir",
        itemId = 9155,
        reagents = {{
            itemId = 8839,
            amount = 1
        }, {
            itemId = 3821,
            amount = 1
        }}
    }, {
        name = "Ghost Dye",
        itemId = 9210,
        reagents = {{
            itemId = 8845,
            amount = 2
        }, {
            itemId = 4342,
            amount = 1
        }}
    }, {
        name = "Invisibility Potion",
        itemId = 9172,
        reagents = {{
            itemId = 8845,
            amount = 1
        }, {
            itemId = 8838,
            amount = 1
        }}
    }, {
        name = "Elixir of Greater Agility",
        itemId = 9187,
        reagents = {{
            itemId = 8838,
            amount = 1
        }, {
            itemId = 3821,
            amount = 1
        }}
    }, {
        name = "Elixir of Dream Vision",
        itemId = 9197,
        reagents = {{
            itemId = 8831,
            amount = 3
        }}
    }, {
        name = "Elixir of Greater Intellect",
        itemId = 9179,
        reagents = {{
            itemId = 8839,
            amount = 1
        }, {
            itemId = 3358,
            amount = 1
        }}
    }, {
        name = "Elixir of Demonslaying",
        itemId = 9224,
        reagents = {{
            itemId = 8846,
            amount = 1
        }, {
            itemId = 8845,
            amount = 1
        }}
    }, {
        name = "Elixir of Detect Demon",
        itemId = 9233,
        reagents = {{
            itemId = 8846,
            amount = 2
        }}
    }, {
        name = "Elixir of Shadow Power",
        itemId = 9264,
        reagents = {{
            itemId = 8845,
            amount = 3
        }}
    }, {
        name = "Catseye Elixir",
        itemId = 10592,
        reagents = {{
            itemId = 3821,
            amount = 1
        }, {
            itemId = 3818,
            amount = 1
        }}
    }, {
        name = "Dreamless Sleep Potion",
        itemId = 12190,
        reagents = {{
            itemId = 8831,
            amount = 3
        }}
    }, {
        name = "Arcanite Bar",
        itemId = 12360,
        reagents = {{
            itemId = 12359,
            amount = 1
        }, {
            itemId = 12363,
            amount = 1
        }}
    }, {
        name = "Living Essence",
        itemId = 12803,
        reagents = {{
            itemId = 7076,
            amount = 1
        }}
    }, {
        name = "Essence of Undeath",
        itemId = 12808,
        reagents = {{
            itemId = 7080,
            amount = 1
        }}
    }, {
        name = "Elixir of Superior Defense",
        itemId = 13445,
        reagents = {{
            itemId = 13423,
            amount = 2
        }, {
            itemId = 8838,
            amount = 1
        }}
    }, {
        name = "Mighty Rage Potion",
        itemId = 13442,
        reagents = {{
            itemId = 8846,
            amount = 3
        }}
    }, {
        name = "Major Mana Potion",
        itemId = 13444,
        reagents = {{
            itemId = 13463,
            amount = 3
        }, {
            itemId = 13467,
            amount = 2
        }}
    }, {
        name = "Elixir of the Sages",
        itemId = 13447,
        reagents = {{
            itemId = 13463,
            amount = 1
        }, {
            itemId = 13466,
            amount = 2
        }}
    }, {
        name = "Superior Mana Potion",
        itemId = 13443,
        reagents = {{
            itemId = 8838,
            amount = 2
        }, {
            itemId = 8839,
            amount = 2
        }}
    }, {
        name = "Major Healing Potion",
        itemId = 13446,
        reagents = {{
            itemId = 13464,
            amount = 2
        }, {
            itemId = 13465,
            amount = 1
        }}
    }, {
        name = "Stonescale Oil",
        itemId = 13423,
        reagents = {{
            itemId = 13422,
            amount = 1
        }}
    }, {
        name = "Elixir of the Mongoose",
        itemId = 13452,
        reagents = {{
            itemId = 13465,
            amount = 2
        }, {
            itemId = 13466,
            amount = 2
        }}
    }, {
        name = "Elixir of Brute Force",
        itemId = 13453,
        reagents = {{
            itemId = 8846,
            amount = 2
        }, {
            itemId = 13466,
            amount = 2
        }}
    }, {
        name = "Greater Arcane Elixir",
        itemId = 13454,
        reagents = {{
            itemId = 13463,
            amount = 3
        }, {
            itemId = 13465,
            amount = 1
        }}
    }, {
        name = "Greater Frost Protection Potion",
        itemId = 13456,
        reagents = {{
            itemId = 7070,
            amount = 1
        }, {
            itemId = 13463,
            amount = 1
        }}
    }, {
        name = "Greater Stoneshield Potion",
        itemId = 13455,
        reagents = {{
            itemId = 13423,
            amount = 2
        }, {
            itemId = 10620,
            amount = 1
        }}
    }, {
        name = "Greater Nature Protection Potion",
        itemId = 13458,
        reagents = {{
            itemId = 7067,
            amount = 1
        }, {
            itemId = 13463,
            amount = 1
        }}
    }, {
        name = "Greater Shadow Protection Potion",
        itemId = 13459,
        reagents = {{
            itemId = 3824,
            amount = 1
        }, {
            itemId = 13463,
            amount = 1
        }}
    }, {
        name = "Greater Fire Protection Potion",
        itemId = 13457,
        reagents = {{
            itemId = 7068,
            amount = 1
        }, {
            itemId = 13463,
            amount = 1
        }}
    }, {
        name = "Greater Arcane Protection Potion",
        itemId = 13461,
        reagents = {{
            itemId = 11176,
            amount = 1
        }, {
            itemId = 13463,
            amount = 1
        }}
    }, {
        name = "Purification Potion",
        itemId = 13462,
        reagents = {{
            itemId = 13467,
            amount = 2
        }, {
            itemId = 13466,
            amount = 2
        }}
    }, {
        name = "Alchemist's Stone",
        itemId = 13503,
        reagents = {{
            itemId = 9149,
            amount = 1
        }, {
            itemId = 25867,
            amount = 1
        }, {
            itemId = 25868,
            amount = 1
        }, {
            itemId = 22794,
            amount = 2
        }, {
            itemId = 23571,
            amount = 5
        }}
    }, {
        name = "Flask of the Titans",
        itemId = 13510,
        reagents = {{
            itemId = 8846,
            amount = 7
        }, {
            itemId = 13423,
            amount = 3
        }, {
            itemId = 13468,
            amount = 1
        }}
    }, {
        name = "Flask of Distilled Wisdom",
        itemId = 13511,
        reagents = {{
            itemId = 13463,
            amount = 7
        }, {
            itemId = 13467,
            amount = 3
        }, {
            itemId = 13468,
            amount = 1
        }}
    }, {
        name = "Flask of Chromatic Resistance",
        itemId = 13513,
        reagents = {{
            itemId = 13467,
            amount = 7
        }, {
            itemId = 13465,
            amount = 3
        }, {
            itemId = 13468,
            amount = 1
        }}
    }, {
        name = "Flask of Supreme Power",
        itemId = 13512,
        reagents = {{
            itemId = 13463,
            amount = 7
        }, {
            itemId = 13465,
            amount = 3
        }, {
            itemId = 13468,
            amount = 1
        }}
    }, {
        name = "Elixir of Frost Power",
        itemId = 17708,
        reagents = {{
            itemId = 3819,
            amount = 2
        }, {
            itemId = 3358,
            amount = 1
        }}
    }, {
        name = "Major Rejuvenation Potion",
        itemId = 18253,
        reagents = {{
            itemId = 10286,
            amount = 1
        }, {
            itemId = 13464,
            amount = 4
        }, {
            itemId = 13463,
            amount = 4
        }}
    }, {
        name = "Elixir of Greater Water Breathing",
        itemId = 18294,
        reagents = {{
            itemId = 7972,
            amount = 1
        }, {
            itemId = 8831,
            amount = 2
        }}
    }, {
        name = "Greater Dreamless Sleep Potion",
        itemId = 20002,
        reagents = {{
            itemId = 13463,
            amount = 2
        }, {
            itemId = 13464,
            amount = 1
        }}
    }, {
        name = "Mighty Troll's Blood Elixir",
        itemId = 20004,
        reagents = {{
            itemId = 8846,
            amount = 1
        }, {
            itemId = 13466,
            amount = 2
        }}
    }, {
        name = "Mageblood Elixir",
        itemId = 20007,
        reagents = {{
            itemId = 13463,
            amount = 1
        }, {
            itemId = 13466,
            amount = 2
        }}
    }, {
        name = "Living Action Potion",
        itemId = 20008,
        reagents = {{
            itemId = 13467,
            amount = 2
        }, {
            itemId = 13465,
            amount = 2
        }, {
            itemId = 10286,
            amount = 2
        }}
    }, {
        name = "Elixir of Greater Firepower",
        itemId = 21546,
        reagents = {{
            itemId = 6371,
            amount = 3
        }, {
            itemId = 4625,
            amount = 3
        }}
    }, {
        name = "Elixir of Firepower",
        itemId = 6373,
        reagents = {{
            itemId = 6371,
            amount = 2
        }, {
            itemId = 3356,
            amount = 1
        }}
    }}
}
end
end

local bag_browser = require("bag_browser")
local simplex_generator = require("simplex_generator")
local available_recipes_finder = require("available_recipes_finder")
local alchemy_recipes = require("static_data.alchemy_recipes")
local auction_data_browser = require("auction_data_browser")
local helpers = require("helpers")
local simplex_solver = require("simplex_calculator.core")



local resultFrame = CreateFrame("Frame", "MyAddonResultFrame", UIParent)
resultFrame:SetSize(300, 400)
resultFrame:SetPoint("CENTER")
resultFrame:SetMovable(true)
resultFrame:EnableMouse(true)
resultFrame:SetScript("OnMouseDown", function(self, button)
    if button == "LeftButton" then
        self:StartMoving()
    end
end)
resultFrame:SetScript("OnMouseUp", function(self, button)
    self:StopMovingOrSizing()
end)
resultFrame:Hide()

local resultText = resultFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
resultText:SetPoint("TOPLEFT", 10, -10)
resultText:SetWidth(resultFrame:GetWidth() - 20)
resultText:SetHeight(resultFrame:GetHeight() - 20)
resultText:SetJustifyV("TOP")
resultText:SetJustifyH("LEFT")

local function OnButtonClick()
    if resultFrame:IsShown() then
        resultFrame:Hide()
    else
        resultFrame:Show()
    end

    local player_name = UnitName("player")
    local realm_name = string.gsub(GetRealmName(), "%s+", "")

    local raw_bag_data = BrotherBags[realm_name][player_name]

    local auction_data = auction_data_browser.get_auctions_from_raw_data(AuctionDBSaved, player_name, realm_name)

    local herbs_in_bag = bag_browser.get_all_herbs_from_inventory(raw_bag_data)

    local available_recipes = available_recipes_finder.get_available_recipes_from_inventory(herbs_in_bag,
        alchemy_recipes)

    local recipe_ids = helpers.get_item_ids_from_recipes(available_recipes)

    local herb_ids = helpers.get_herb_ids_from_bag_data(herbs_in_bag)
    local all_item_ids = helpers.concat_tables(recipe_ids, herb_ids)

    local prices_from_full_mock_auctions = auction_data_browser.get_prices_from_ids(all_item_ids, auction_data)

    local generated_matrix = simplex_generator.construct_simplex_matrix_from_data(herbs_in_bag, available_recipes,
        prices_from_full_mock_auctions);

    local copied_matrix_with_ids = generated_matrix;
    generated_matrix = (simplex_generator.strip_tag_data_from_matrix(generated_matrix))
    simplex_solver.solve_simplex_task(generated_matrix)
    local results = helpers.extract_results_from_solved_matrix(generated_matrix, copied_matrix_with_ids)

    local resultString = ""
    for _, result in ipairs(results) do
        local itemId = result[1]
        local itemCount = result[2]
        local reagents = available_recipes_finder.get_reagents_from_recipe_id(itemId, available_recipes)
        local itemName, _, itemRarity, _, _, _, _, _, _, itemIcon = GetItemInfo(itemId)

        if itemName then
            resultString = resultString .. "|T" .. itemIcon .. ":0|t " .. itemName .. ":" .. itemCount .. "x\n"
            if reagents then
                for _, reagent in ipairs(reagents) do
                    local reagentName, _, _, _, _, _, _, _, _, reagentIcon = GetItemInfo(reagent.itemId)
                    if reagentName then
                        resultString = resultString .. "      |T" .. reagentIcon .. ":0|t " .. reagentName .. ":" ..
                                           reagent.amount .. "\n"
                    end
                end
            end
        else
            resultString = resultString .. itemId .. ":" .. itemCount .. "x\n"
        end
    end
    resultText:SetText(resultString)
end

local buttonFrame = CreateFrame("Button", "MyAddonMinimapButton", UIParent)
buttonFrame:SetSize(32, 32)
buttonFrame:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

buttonFrame.icon = buttonFrame:CreateTexture(nil, "BACKGROUND")
buttonFrame.icon:SetAllPoints()
buttonFrame.icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")

buttonFrame:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 10, -10)
buttonFrame:SetMovable(true)
buttonFrame:SetScript("OnMouseDown", function(self, button)
    if button == "LeftButton" then
        self:StartMoving()
    end
end)
buttonFrame:SetScript("OnMouseUp", function(self, button)
    self:StopMovingOrSizing()
end)
buttonFrame:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    GameTooltip:SetText("Goldbrew")
    GameTooltip:AddLine("Click to show/hide the results of simplex method.")
    GameTooltip:Show()
end)
buttonFrame:SetScript("OnLeave", function(self)
    GameTooltip:Hide()
end)

buttonFrame:SetScript("OnClick", function(self, button)
    if button == "LeftButton" then
        OnButtonClick()
    end
end)


