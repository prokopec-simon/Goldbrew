local function get_item_ids_from_recipes(availableRecipes)
    local itemIds = {}

    for _, recipe in ipairs(availableRecipes) do
        table.insert(itemIds, recipe.itemId)
    end

    return itemIds
end

local function concat_tables(t1, t2)
    for i = 1, #t2 do
        t1[#t1 + 1] = t2[i]
    end
    return t1
end

return {
    get_item_ids_from_recipes = get_item_ids_from_recipes,
    concat_tables = concat_tables
}
