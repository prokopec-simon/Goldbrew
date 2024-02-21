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

return {
    get_item_ids_from_recipes = get_item_ids_from_recipes,
    concat_tables = concat_tables,
    print_matrix = print_matrix,
    table_length = table_length,
    get_nth_item = get_nth_item,
    find_price_by_item_id = find_price_by_item_id
}
