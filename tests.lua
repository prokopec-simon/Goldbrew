local helpers = require("helpers")

-- ============== Inventory testing ==============
local mocked_inventory = require("mock_data.mock_bag_full")
local bag_browser = require("bag_browser")

-- Parsing mock inventory
local raw_mock_bag_data = mocked_inventory["LoneWolf"]["Eluff"]
local clean_bag_data = bag_browser.get_bag_contents(raw_mock_bag_data)
local herbs_in_bag = bag_browser.get_all_herbs_from_inventory(clean_bag_data)

-- There should be 45 entries in the mock inventory after cleaning
helpers.simple_assert(#clean_bag_data, 45)
-- The first item should be this: '6948::::::::25:::::::::'
helpers.simple_assert(clean_bag_data[1], "6948::::::::25:::::::::")
-- The first pair should represent 40 items of Id 7067
local firstId, firstCount = next(herbs_in_bag)
helpers.simple_assert(firstId, 7067)
helpers.simple_assert(firstCount, 40)

-- =================================================

-- ============== Data cleanup & preparation testing ==============
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
-- ==================================================
