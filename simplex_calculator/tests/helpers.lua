local function print_matrix(tableau)
    for i = 1, #tableau do
        local numeric_format = "%.2f";
        for j = 1, #tableau[i] do
            io.write(string.format(numeric_format, tableau[i][j]))
            if j < #tableau[i] then
                io.write("\t")
            end
        end
        io.write("\n")
    end
end

return {
    print_matrix = print_matrix
}
