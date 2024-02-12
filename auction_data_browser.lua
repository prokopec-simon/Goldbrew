local function get_prices_from_ids(item_ids, database_data)
    local items = {}

    for item in database_data:gmatch("i[^i]+") do
        local item_id, item_info = item:match("i([^?!]+)[?!](.+)")
        local buyout_price = item_info:match("[^,]+,[^,]+,([^,]+)")

        -- Check if itemId is in item_ids
        if has_value(item_ids, tonumber(item_id)) then
            -- Insert data into the table only if itemId is in item_ids
            table.insert(items, {
                item_id = item_id,
                buyout_price = buyout_price
            })
        end
    end

    return items
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
    get_prices_from_ids = get_prices_from_ids
}

