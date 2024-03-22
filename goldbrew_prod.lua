local button = CreateFrame("Button", "MyAddonButton", UIParent, "UIPanelButtonTemplate")
button:SetPoint("RIGHT")
button:SetText("Debug")

local function OnButtonClick()
    print("yoyo")
    print(GetBagContents("LoneWolf", "Eluff"))
end

local function GetBagContents(realm, character)
    local raw_bag_data = BrotherBags[realm][character]
    local clean_bag_data = bag_browser.get_bag_contents(raw_bag_data)
    local herbs_in_bag = bag_browser.get_all_herbs_from_inventory(clean_bag_data)

end
button:SetScript("OnClick", OnButtonClick)
