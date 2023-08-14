local button = CreateFrame("Button", "MyAddonButton", UIParent, "UIPanelButtonTemplate")
button:SetPoint("RIGHT")
button:SetText("Debugging btn")

local function OnButtonClick()
    local herbsByIdWithAmount = getHerbsFromBags();
    local productIds = getProductIdsFromAvailableHerbs(herbsByIdWithAmount);
    local herbAndProductToSearchIds = productIds + herbsByIdWithAmount;
    local auctionPrices = getAuctionPricesForAvailableHerbsAndProducts(herbAndProductToSearchIds)
end

local function getProductIdsFromAvailableHerbs()

end

local function convertPricesAndAmountsToSimplexMatrix()

end
button:SetScript("OnClick", OnButtonClick)
