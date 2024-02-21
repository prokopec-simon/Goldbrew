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
