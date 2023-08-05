local button = CreateFrame("Button", "MyAddonButton", UIParent, "UIPanelButtonTemplate")
button:SetPoint("RIGHT")
button:SetText("Debugging btn")

local function OnButtonClick()
    local myAddonData = AuctionDBSaved["ah"][1]["data"]
    local auctions = splitAuctions(myAddonData)

    for _, auction in ipairs(auctions) do
        print("V4Key: " .. auction.v4key .. ", Buyout Price: " .. auction.buyoutPrice)
    end

end

button:SetScript("OnClick", OnButtonClick)

function splitAuctions(dataString)
    local auctions = {}
    for v4key, seller, buyoutPrice in dataString:gmatch("(i%d+%?.-)%!/(.-)%,%d+,%d+,(%d+),.-") do
        seller = seller or ""
        table.insert(auctions, {
            v4key = v4key .. "!" .. seller,
            buyoutPrice = tonumber(buyoutPrice)
        })
    end
    return auctions
end
