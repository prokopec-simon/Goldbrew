local function extract_final_value_from_tableau(tableau)
    local numRows = #tableau
    local lastRow = tableau[numRows]
    local numColumns = #lastRow
    local lastColumnValue = lastRow[numColumns]
    return lastColumnValue
end

return {
    getResultFromTableau = extract_final_value_from_tableau,
}
