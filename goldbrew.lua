local button = CreateFrame("Button", "MyAddonButton", UIParent, "UIPanelButtonTemplate")
button:SetPoint("RIGHT")
button:SetText("Debugging btn")

local function OnButtonClick()
    local herbsByIdWithAmount = getHerbsFromBags();
    local auctionPrices = getAuctionPricesForAvailableMaterials(herbsByIdWithAmount)
end

button:SetScript("OnClick", OnButtonClick)
