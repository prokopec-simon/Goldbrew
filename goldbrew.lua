local bag_browser = require("bag_browser")
local simplex_generator = require("simplex_generator")
local available_recipes_finder = require("available_recipes_finder")
local alchemy_recipes = require("static_data.alchemy_recipes")
local auction_data_browser = require("auction_data_browser")
local helpers = require("helpers")
local simplex_solver = require("simplex_calculator.core")

-- dev_start
local cmd_argument = arg[1]

if cmd_argument == "-DEV" then
    local mock_full_bag_data = require("mock_data.mock_bag_full")
    local mock_full_auctions_data = require("mock_data.mock_auctions_full")
    local raw_mock_bag_data = mock_full_bag_data["LoneWolf"]["Eluff"]
    local auctions_from_full_mock_data = auction_data_browser.get_auctions_from_raw_data(mock_full_auctions_data,
        "Eluff", "LoneWolf")

    local herbs_in_bag = bag_browser.get_all_herbs_from_inventory(raw_mock_bag_data)

    local available_recipes = available_recipes_finder.get_available_recipes_from_inventory(herbs_in_bag,
        alchemy_recipes)

    local recipe_ids = helpers.get_item_ids_from_recipes(available_recipes)
    local herb_ids = helpers.get_herb_ids_from_bag_data(herbs_in_bag)

    local all_item_ids = helpers.concat_tables(recipe_ids, herb_ids)

    local prices_from_full_mock_auctions = auction_data_browser.get_prices_from_ids(all_item_ids,
        auctions_from_full_mock_data)

    -- create simplex matrix
    local generated_matrix = simplex_generator.construct_simplex_matrix_from_data(herbs_in_bag, available_recipes,
        prices_from_full_mock_auctions);
    helpers.print_matrix(generated_matrix)

    local copied_matrix_with_ids = generated_matrix;
    generated_matrix = (simplex_generator.strip_tag_data_from_matrix(generated_matrix))
    simplex_solver.solve_simplex_task(generated_matrix)
    print("---")
    helpers.print_matrix(generated_matrix)
    local results = helpers.extract_results_from_solved_matrix(generated_matrix, copied_matrix_with_ids)

    print("----------------------")
    for _, result in ipairs(results) do
        print("Item ID:", result[1])
        print("Amount:", result[2])
        print("----------------------")
    end
end
-- dev_end

-- prod
