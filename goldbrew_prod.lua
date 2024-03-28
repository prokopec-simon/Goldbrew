local resultFrame = CreateFrame("Frame", "MyAddonResultFrame", UIParent)
resultFrame:SetSize(300, 400)
resultFrame:SetPoint("CENTER")
resultFrame:SetMovable(true)
resultFrame:EnableMouse(true)
resultFrame:SetScript("OnMouseDown", function(self, button)
    if button == "LeftButton" then
        self:StartMoving()
    end
end)
resultFrame:SetScript("OnMouseUp", function(self, button)
    self:StopMovingOrSizing()
end)
resultFrame:Hide()

local resultText = resultFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
resultText:SetPoint("TOPLEFT", 10, -10)
resultText:SetWidth(resultFrame:GetWidth() - 20)
resultText:SetHeight(resultFrame:GetHeight() - 20)
resultText:SetJustifyV("TOP")
resultText:SetJustifyH("LEFT")

local function OnButtonClick()
    if resultFrame:IsShown() then
        resultFrame:Hide()
    else
        resultFrame:Show()
    end

    local player_name = UnitName("player")
    local realm_name = string.gsub(GetRealmName(), "%s+", "")

    local raw_bag_data = BrotherBags[realm_name][player_name]

    local auction_data = auction_data_browser.get_auctions_from_raw_data(AuctionDBSaved, player_name, realm_name)

    local herbs_in_bag = bag_browser.get_all_herbs_from_inventory(raw_bag_data)

    local available_recipes = available_recipes_finder.get_available_recipes_from_inventory(herbs_in_bag,
        alchemy_recipes)

    local recipe_ids = helpers.get_item_ids_from_recipes(available_recipes)

    local herb_ids = helpers.get_herb_ids_from_bag_data(herbs_in_bag)
    local all_item_ids = helpers.concat_tables(recipe_ids, herb_ids)

    local prices_from_full_mock_auctions = auction_data_browser.get_prices_from_ids(all_item_ids, auction_data)

    local generated_matrix = simplex_generator.construct_simplex_matrix_from_data(herbs_in_bag, available_recipes,
        prices_from_full_mock_auctions);

    local copied_matrix_with_ids = generated_matrix;
    generated_matrix = (simplex_generator.strip_tag_data_from_matrix(generated_matrix))
    simplex_solver.solve_simplex_task(generated_matrix)
    local results = helpers.extract_results_from_solved_matrix(generated_matrix, copied_matrix_with_ids)

    local resultString = ""
    for _, result in ipairs(results) do
        local itemId = result[1]
        local itemCount = result[2]
        local reagents = available_recipes_finder.get_reagents_from_recipe_id(itemId, available_recipes)
        local itemName, _, itemRarity, _, _, _, _, _, _, itemIcon = GetItemInfo(itemId)

        if itemName then
            resultString = resultString .. "|T" .. itemIcon .. ":0|t " .. itemName .. ":" .. itemCount .. "x\n"
            if reagents then
                for _, reagent in ipairs(reagents) do
                    local reagentName, _, _, _, _, _, _, _, _, reagentIcon = GetItemInfo(reagent.itemId)
                    if reagentName then
                        resultString = resultString .. "      |T" .. reagentIcon .. ":0|t " .. reagentName .. ":" ..
                                           reagent.amount .. "\n"
                    end
                end
            end
        else
            resultString = resultString .. itemId .. ":" .. itemCount .. "x\n"
        end
    end
    resultText:SetText(resultString)
end

local buttonFrame = CreateFrame("Button", "MyAddonMinimapButton", UIParent)
buttonFrame:SetSize(32, 32)
buttonFrame:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

buttonFrame.icon = buttonFrame:CreateTexture(nil, "BACKGROUND")
buttonFrame.icon:SetAllPoints()
buttonFrame.icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")

buttonFrame:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 10, -10)
buttonFrame:SetMovable(true)
buttonFrame:SetScript("OnMouseDown", function(self, button)
    if button == "LeftButton" then
        self:StartMoving()
    end
end)
buttonFrame:SetScript("OnMouseUp", function(self, button)
    self:StopMovingOrSizing()
end)
buttonFrame:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    GameTooltip:SetText("Goldbrew")
    GameTooltip:AddLine("Click to show/hide the results of simplex method.")
    GameTooltip:Show()
end)
buttonFrame:SetScript("OnLeave", function(self)
    GameTooltip:Hide()
end)

buttonFrame:SetScript("OnClick", function(self, button)
    if button == "LeftButton" then
        OnButtonClick()
    end
end)
