local bag_browser = require("bag_browser")

local button = CreateFrame("Button", "MyAddonButton", UIParent, "UIPanelButtonTemplate")
button:SetPoint("RIGHT")
button:SetText("Debug")

local function OnButtonClick()
    print("Hello World!")

    local bag_content = bag_browser.get_addon_bag_data("LoneWolf", "Eluff")
    local clean_bag = bag_browser.get_bag_contents(bag_content)
    local herbs_in_bag = bag_browser.get_all_herbs_from_inventory(clean_bag)
    for id, count in pairs(herbs_in_bag) do
        print("Item ID: " .. id .. ", Count: " .. count)
    end
end

button:SetScript("OnClick", OnButtonClick)
