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
