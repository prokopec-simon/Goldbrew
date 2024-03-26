local button = CreateFrame("Button", "MyAddonButton", UIParent, "UIPanelButtonTemplate")
button:SetPoint("TOP")
button:SetText("Debug")

local function OnButtonClick()
    local player_name = UnitName("player");
    local realm_name = string.gsub(GetRealmName(), "%s+", "")

    local raw_bag_data = BrotherBags[realm_name][player_name]

    local auction_data = auction_data_browser.get_auctions_from_raw_data(AuctionDBSaved, player_name, realm_name)

    local herbs_in_bag = bag_browser.get_all_herbs_from_inventory(raw_bag_data)

    local available_recipes = available_recipes_finder.get_available_recipes_from_inventory(herbs_in_bag,
        alchemy_recipes)

    local recipe_ids = helpers.get_item_ids_from_recipes(available_recipes)

    local herb_ids = helpers.get_herb_ids_from_bag_data(herbs_in_bag)
    local all_item_ids = helpers.concat_tables(recipe_ids, herb_ids)

    local prices_from_full_mock_auctions = auction_data_browser.get_prices_from_ids(all_item_ids, auction_data)

    local generated_matrix = simplex_generator.construct_simplex_matrix_from_data(herbs_in_bag, available_recipes,
        prices_from_full_mock_auctions);

    local copied_matrix_with_ids = generated_matrix;
    generated_matrix = (simplex_generator.strip_tag_data_from_matrix(generated_matrix))
    simplex_solver.solve_simplex_task(generated_matrix)
    local results = helpers.extract_results_from_solved_matrix(generated_matrix, copied_matrix_with_ids)

    for _, result in ipairs(results) do
        print(result[1] .. ":" .. result[2] .. "x")
    end
end

button:SetScript("OnClick", OnButtonClick)
