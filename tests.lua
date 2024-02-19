-- Importing modules
local auction_data_browser = require("auction_data_browser")
local bag_browser = require("bag_browser")
local alchemy_recipes = require("alchemy_recipes")
local available_recipes_finder = require("available_recipes_finder")
local helpers = require("helpers")
local mock_bag_data = require("mock_data.mock_bag")
local mock_auctions_data = require("mock_data.mock_auctions_part")
local mock_full_auctions_data = require("mock_data.mock_auctions_full")

-- Mock data setup
local raw_bag_data = mock_bag_data["LoneWolf"]["Eluff"]
local clean_bag_data = bag_browser.get_bag_contents(raw_bag_data)
local herbs_in_bag = bag_browser.get_all_herbs_from_inventory(clean_bag_data)

-- Find available recipes in the inventory
local available_recipes = available_recipes_finder.get_available_recipes_from_inventory(herbs_in_bag, alchemy_recipes)

-- Display herbs in the mock bag
for herb_id, count in pairs(herbs_in_bag) do
    print("Herb ID: " .. herb_id .. ", Count: " .. count)
end

-- Display available recipes
for _, recipe in ipairs(available_recipes) do
    print("Can craft: " .. recipe.itemId .. "-" .. recipe.name)
end

-- Get item and herb IDs
local recipe_ids = helpers.get_item_ids_from_recipes(available_recipes)
local herb_ids = {}
for id, count in pairs(herbs_in_bag) do
    table.insert(herb_ids, id)
end

-- Display item and herb IDs
print("Recipe Item IDs: " .. table.concat(recipe_ids, ", "))
print("Herb Item IDs: " .. table.concat(herb_ids, ", "))
print("All IDs: " .. table.concat(helpers.concat_tables(recipe_ids, herb_ids), ", "))

-- Get prices from mock auction data
local all_item_ids = helpers.concat_tables(recipe_ids, herb_ids)
local prices_from_mock_auctions = auction_data_browser.get_prices_from_ids(all_item_ids, mock_auctions_data)

-- Get auctions from mock auction data and display buyout prices
local auctions_from_full_mock_data = auction_data_browser.get_auctions_from_raw_data(mock_full_auctions_data, "Eluff",
    "LoneWolf")
local prices_from_full_mock_auctions = auction_data_browser.get_prices_from_ids(all_item_ids,
    auctions_from_full_mock_data)

for _, item in ipairs(prices_from_full_mock_auctions) do
    print("Item ID: " .. item.item_id .. ", Buyout Price: " .. item.buyout_price)
end
