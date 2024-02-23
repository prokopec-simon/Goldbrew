local function extract_final_value_from_tableau(tableau)
    local numRows = #tableau
    local lastRow = tableau[numRows]
    local numColumns = #lastRow
    local lastColumnValue = lastRow[numColumns]
    return lastColumnValue
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

return {
    getResultFromTableau = extract_final_value_from_tableau,
    extract_results_from_solved_matrix = extract_results_from_solved_matrix
}
