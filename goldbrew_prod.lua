local button = CreateFrame("Button", "MyAddonButton", UIParent, "UIPanelButtonTemplate")
button:SetPoint("RIGHT")
button:SetText("Debug")

local function OnButtonClick()
    local raw_bag_data = BrotherBags["LoneWolf"]["Eluff"]
    local clean_bag_data = bag_browser.get_bag_contents(raw_bag_data)
    local herbs_in_bag = bag_browser.get_all_herbs_from_inventory(clean_bag_data)

    local recipe_ids = helpers.get_item_ids_from_recipes(available_recipes)
    local herb_ids = {}
    for id, count in pairs(herbs_in_bag) do
        table.insert(herb_ids, id)
    end
    local all_item_ids = helpers.concat_tables(recipe_ids, herb_ids)
    for id in all_item_ids do
        print(id)
    end

    -- local auction_data = AuctionDBSaved["ah"]
    -- print(#auction_data)
    -- local auctions_from_full_mock_data = auction_data_browser.get_auctions_from_raw_data(auction_data, "Eluff",
    --     "LoneWolf")
    -- local prices_from_full_mock_auctions = auction_data_browser.get_prices_from_ids(all_item_ids,
    --     auctions_from_full_mock_data)

    -- -- create simplex matrix
    -- local generated_matrix = simplex_generator.construct_simplex_matrix_from_data(herbs_in_bag, available_recipes,
    --     prices_from_full_mock_auctions);
    -- helpers.print_matrix(generated_matrix)

    -- local copied_matrix_with_ids = generated_matrix;
    -- generated_matrix = (simplex_generator.strip_tag_data_from_matrix(generated_matrix))
    -- simplex_solver.solve_simplex_task(generated_matrix)
    -- print("---")
    -- helpers.print_matrix(generated_matrix)
    -- local results = helpers.extract_results_from_solved_matrix(generated_matrix, copied_matrix_with_ids)

    -- print("----------------------")
    -- for _, result in ipairs(results) do
    --     print("Item ID:", result[1])
    --     print("Amount:", result[2])
    --     print("----------------------")
    -- end
end

button:SetScript("OnClick", OnButtonClick)
