local function get_prices_from_ids(item_ids, database_data)
    local items = {}

    for item in database_data:gmatch("i[^i]+") do
        local item_id, item_info = item:match("i([^?!]+)[?!](.+)")
        local buyout_price = item_info:match("[^,]+,[^,]+,([^,]+)")

        if has_value(item_ids, tonumber(item_id)) then
            table.insert(items, {
                item_id = item_id,
                buyout_price = buyout_price
            })
        end
    end

    return items
end

local function get_auctions_from_raw_data(auction_data, character_name, realm_name)
    local char = character_name .. "-" .. realm_name;
    local data = {};
    for _, characterData in ipairs(auction_data["ah"]) do
        if characterData["char"] == char then
            table.insert(data, 0, characterData["data"]);
        end
    end
    local concatenated_data = table.concat(data, "");

    return concatenated_data
end

function has_value(tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

return {
    get_prices_from_ids = get_prices_from_ids,
    get_auctions_from_raw_data = get_auctions_from_raw_data
}

