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
