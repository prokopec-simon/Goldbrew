local bag_browser = require("bag_browser")
local simplex_generator = require("simplex_generator")
local available_recipes_finder = require("available_recipes_finder")
local alchemy_recipes = require("static_data.alchemy_recipes")
local auction_data_browser = require("auction_data_browser")
local helpers = require("helpers")

local mock_full_bag_data = require("mock_data.mock_bag_full")
local mock_full_auctions_data = require("mock_data.mock_auctions_full")

local cmd_argument = arg[1]

-- if cmd_argument == "-DEV" then
-- bag contents
local raw_mock_bag_data = mock_full_bag_data["LoneWolf"]["Eluff"]
local clean_bag_data = bag_browser.get_bag_contents(raw_mock_bag_data)
local herbs_in_bag = bag_browser.get_all_herbs_from_inventory(clean_bag_data)

-- available recipes
local available_recipes = available_recipes_finder.get_available_recipes_from_inventory(herbs_in_bag, alchemy_recipes)

-- auction data
local recipe_ids = helpers.get_item_ids_from_recipes(available_recipes)
local herb_ids = {}
for id, count in pairs(herbs_in_bag) do
    table.insert(herb_ids, id)
end

local all_item_ids = helpers.concat_tables(recipe_ids, herb_ids)
local auctions_from_full_mock_data = auction_data_browser.get_auctions_from_raw_data(mock_full_auctions_data, "Eluff",
    "LoneWolf")
local prices_from_full_mock_auctions = auction_data_browser.get_prices_from_ids(all_item_ids,
    auctions_from_full_mock_data)

-- create simplex matrix
local generated_matrix = simplex_generator.construct_simplex_matrix_from_data(herbs_in_bag, available_recipes,
    prices_from_full_mock_auctions);
helpers.print_matrix(generated_matrix)

-- else
-- local button = CreateFrame("Button", "MyAddonButton", UIParent, "UIPanelButtonTemplate")
-- button:SetPoint("RIGHT")
-- button:SetText("Debug")

-- local function OnButtonClick()
--     print("yoyo")
-- end

-- local function GetBagContents(realm, character)
--     local raw_bag_data = BrotherBags[realm][character]
--     local clean_bag_data = bag_browser.get_bag_contents(raw_bag_data)
--     local herbs_in_bag = bag_browser.get_all_herbs_from_inventory(clean_bag_data)

-- end
-- button:SetScript("OnClick", OnButtonClick)
-- end

