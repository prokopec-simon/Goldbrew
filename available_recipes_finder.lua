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
