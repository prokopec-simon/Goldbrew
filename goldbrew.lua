local button = CreateFrame("Button", "MyAddonButton", UIParent, "UIPanelButtonTemplate")
button:SetPoint("RIGHT")
button:SetText("Debugging btn")

local function OnButtonClick()
    local myAddonData = AuctionDBSaved["ah"][1]["data"]
    local itemIDs = {
        ["7473"] = true,
        ["14218"] = true
    }
    local auctions = splitAuctions(myAddonData, itemIDs)

    for _, auction in ipairs(auctions) do
        print("Item ID: " .. auction.itemID .. ", Buyout Price: " .. auction.buyoutPrice)
    end

    local item = getInventoryContentsFromBagnon()

    print("Item: " .. item)
end

button:SetScript("OnClick", OnButtonClick)

function splitAuctions(dataString, itemIDs)
    local auctions = {}
    for v4key, _, buyoutPrice in dataString:gmatch("(i%d+%?.-)%!/(.-)%,%d+,%d+,(%d+),.-") do
        local itemID = v4key:match("i(%d+)")
        if not itemIDs or itemIDs[itemID] then
            table.insert(auctions, {
                itemID = itemID,
                buyoutPrice = tonumber(buyoutPrice)
            })
        end
    end
    return auctions
end

function getInventoryContentsFromBagnon()
    local myAddonData = BrotherBags["Ashbringer"]["Ahpeon"][0][1]
    return myAddonData
end
