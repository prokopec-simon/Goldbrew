function getHerbsFromBags()
    local bagsContent = BrotherBags["Ashbringer"]["Ahpeon"][0][1]

    local herbIds = {201, 491, 204}

    local herbsWithAmountById = {}
    for _, str in ipairs(bagsContent) do
        local id, amount = str:match("(%d+)::::::::(%d*)")
        if id and amount ~= "" then
            local numericId = tonumber(id)
            for _, herbId in ipairs(herbIds) do
                if numericId == herbId then
                    table.insert(herbsWithAmountById, {numericId, tonumber(amount)})
                    break
                end
            end
        end
    end

    return herbsWithAmountById
end
