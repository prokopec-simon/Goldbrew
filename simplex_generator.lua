local helpers = require("helpers")

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
                simplex_matrix[row_count][i + 1] = helpers.find_price_by_item_id(price_data, recipe_id)
            end
        end
    end

    return simplex_matrix

end

return {
    construct_simplex_matrix_from_data = construct_simplex_matrix_from_data
}
