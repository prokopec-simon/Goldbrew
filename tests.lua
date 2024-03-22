local auction_data_browser = require("auction_data_browser")
local bag_browser = require("bag_browser")
local alchemy_recipes = require("static_data.alchemy_recipes")
local available_recipes_finder = require("available_recipes_finder")
local helpers = require("helpers")

local mocked_inventory = require("mock_data.mock_bag_full")

-- parsing mock inventory
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
