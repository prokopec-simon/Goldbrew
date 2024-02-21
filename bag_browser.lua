local alchemy_material_ids = require("static_data.alchemy_material_ids")

local function get_addon_bag_data(realm, character)
    return BrotherBags[realm][character]
end

local function get_bag_contents(bag_data)
    local concatenated_bags = {}

    for i = 0, 4 do
        local bag_content = bag_data[i]
        if bag_content then
            for _, item in ipairs(bag_content) do
                table.insert(concatenated_bags, item)
            end
        end
    end

    return concatenated_bags
end

local function get_item_counts_by_ids(item_ids, bags_content)
    local item_amounts_by_id = {}

    for _, str in ipairs(bags_content) do
        local string_id, string_amount = str:match("([^:]+)::::::::.-:::::::::;([^:]+)")
        if string_id and string_amount ~= "" then
            local found_item_id = tonumber(string_id)
            for _, lookup_item_id in ipairs(item_ids) do
                if found_item_id == lookup_item_id then
                    table.insert(item_amounts_by_id, {tonumber(found_item_id), tonumber(string_amount)})
                    break
                end
            end
        end
    end

    local summed_item_amounts_by_id = {}

    for _, entry in ipairs(item_amounts_by_id) do
        local id = tonumber(entry[1])
        local count = tonumber(entry[2])

        if summed_item_amounts_by_id[id] then
            summed_item_amounts_by_id[id] = summed_item_amounts_by_id[id] + count
        else
            summed_item_amounts_by_id[id] = count
        end
    end

    return summed_item_amounts_by_id
end

local function get_all_herbs_from_inventory(bag_contents)
    return get_item_counts_by_ids(alchemy_material_ids, bag_contents)
end

return {
    get_all_herbs_from_inventory = get_all_herbs_from_inventory,
    get_bag_contents = get_bag_contents,
    get_item_counts_by_ids = get_item_counts_by_ids,
    get_addon_bag_data = get_addon_bag_data
}
