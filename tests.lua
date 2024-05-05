local helpers = require("helpers")

-- ============== Inventory ==============
local mocked_inventory = require("mock_data.mock_bag_full")
local bag_browser = require("bag_browser")

-- Parsing mock inventory
local raw_mock_bag_data = mocked_inventory["LoneWolf"]["Eluff"]
local herbs_in_bag = bag_browser.get_all_herbs_from_inventory(raw_mock_bag_data)

-- The first pair should represent 40 items of Id 7067
local firstId, firstCount = next(herbs_in_bag)
helpers.simple_assert(firstId, 7067)
helpers.simple_assert(firstCount, 40)
-- =======================================

-- ============ Data cleanup =============
local available_recipes_finder = require("available_recipes_finder")
local alchemy_recipes = require("static_data.alchemy_recipes")

-- Extract Ids from inventory herb data, should contain 14 items
local herb_ids = helpers.get_herb_ids_from_bag_data(herbs_in_bag)
helpers.simple_assert(#herb_ids, 14)

-- The first available recipe should be item Id 118, with 1st reagend being 1 unit of item Id 2447
local available_recipes = available_recipes_finder.get_available_recipes_from_inventory(herbs_in_bag, alchemy_recipes)
helpers.simple_assert(available_recipes[1].itemId, 118)
helpers.simple_assert(available_recipes[1].reagents[1].itemId, 2447)
helpers.simple_assert(available_recipes[1].reagents[1].amount, 1)

-- There should be 22 available recipes
local recipe_ids = helpers.get_item_ids_from_recipes(available_recipes)
helpers.simple_assert(#recipe_ids, 22)

-- Merging all Ids, 5th Id should be 2457, 13th 3383, total of 36 items
local all_item_ids = helpers.concat_tables(recipe_ids, herb_ids)
helpers.simple_assert(all_item_ids[5], 2457)
helpers.simple_assert(all_item_ids[13], 3383)
helpers.simple_assert(#all_item_ids, 36)
-- =======================================

-- ============ Full tests =============
local bag_browser = require("bag_browser")
local simplex_generator = require("simplex_generator")
local available_recipes_finder = require("available_recipes_finder")
local alchemy_recipes = require("static_data.alchemy_recipes")
local auction_data_browser = require("auction_data_browser")
local helpers = require("helpers")
local simplex_solver = require("simplex_calculator.core")
local auction_data_browser = require("auction_data_browser")

local mock_full_bag_data = require("mock_data.mock_bag_simple")
local mock_full_auctions_data = require("mock_data.mock_auctions_full_2")
local raw_mock_bag_data = mock_full_bag_data["LoneWolf"]["Eluff"]
local auctions_from_full_mock_data = auction_data_browser.get_auctions_from_raw_data(mock_full_auctions_data, "Eluff",
    "LoneWolf")

local herbs_in_bag = bag_browser.get_all_herbs_from_inventory(raw_mock_bag_data)
local available_recipes = available_recipes_finder.get_available_recipes_from_inventory(herbs_in_bag, alchemy_recipes)
local recipe_ids = helpers.get_item_ids_from_recipes(available_recipes)
local herb_ids = helpers.get_herb_ids_from_bag_data(herbs_in_bag)
local all_item_ids = helpers.concat_tables(recipe_ids, herb_ids)
local prices_from_full_mock_auctions = auction_data_browser.get_prices_from_ids(all_item_ids,
    auctions_from_full_mock_data)
local generated_matrix = simplex_generator.construct_simplex_matrix_from_data(herbs_in_bag, available_recipes,
    prices_from_full_mock_auctions);
local copied_matrix_with_ids = generated_matrix;
generated_matrix = (simplex_generator.strip_tag_data_from_matrix(generated_matrix))
simplex_solver.solve_simplex_task(generated_matrix)

local results = helpers.extract_results_from_solved_matrix(generated_matrix, copied_matrix_with_ids)

for _, result in ipairs(results) do

    print("Item ID:", result[1])
    local reagents = available_recipes_finder.get_reagents_from_recipe_id(result[1], available_recipes)
    if reagents then
        for _, reagent in ipairs(reagents) do
            print(reagent.itemId)
        end
    end
    print("Amount:", result[2])
end

-- =====================================
