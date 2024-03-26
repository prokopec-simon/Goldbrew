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
