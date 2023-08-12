function splitAuctions(dataString, filterItemIds)
    local auctions = {}
    for v4key, _, buyoutPrice in dataString:gmatch("(i%d+%?.-)%!/(.-)%,%d+,%d+,(%d+),.-") do
        local itemId = v4key:match("i(%d+)")
        if not filterItemIds or filterItemIds[itemId] then
            table.insert(auctions, {
                itemId = tonumber(itemId),
                buyoutPrice = tonumber(buyoutPrice)
            })
        end
    end
    return auctions
end

function getAuctionPricesForAvailableMaterials(herbIds)
    local rawAuctions = AuctionDBSaved["ah"][1]["data"]
    return splitAuctions(splitAuctions, herbIds)
end
