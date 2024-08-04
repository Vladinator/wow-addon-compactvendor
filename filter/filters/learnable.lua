local CompactVendorFilterDropDownToggleWrapperTemplate = CompactVendorFilterDropDownToggleWrapperTemplate ---@type CompactVendorFilterDropDownToggleWrapperTemplate

do

    local filter = CompactVendorFilterDropDownToggleWrapperTemplate:New(
        "Learnable",
        function(self, itemLink, itemData)
            if itemData.isHeirloom then
                return itemData.isKnownHeirloom ~= nil
            end
            if itemData.isToy then
                return itemData.isToyCollected ~= nil
            end
            if itemData.isCosmeticBundle then
                return itemData.isCosmeticBundleCollected ~= nil
            end
            if itemData.isCollected ~= nil then
                return itemData.isCollectedNum ~= nil and itemData.isCollectedNumMax ~= nil
            end
            return not not itemData.isLearnable
        end,
        function(self, value)
            return value and YES or NO
        end,
        true
    )

    filter:Publish()

end

do

    ---@param itemData MerchantItem
    ---@return boolean collectable, boolean collected, number current, number total
    local function GetCollectedStatus(itemData)
        local collectable = false
        local collected = false
        local current = 0
        local total = 0
        if itemData.isHeirloom then
            collectable = true
            collected = itemData.isKnownHeirloom
        elseif itemData.isToy then
            collectable = true
            collected = itemData.isToyCollected
        elseif itemData.isCosmeticBundle then
            collectable = true
            current = itemData.isCosmeticBundleNum ---@type number
            total = itemData.isCosmeticBundleNumMax ---@type number
            collected = itemData.isCosmeticBundleCollected
        elseif itemData.isCollected ~= nil then
            collectable = true
            current = itemData.isCollectedNum ---@type number
            total = itemData.isCollectedNumMax ---@type number
            collected = current == total
        elseif itemData.isLearnable ~= nil then
            collectable = itemData.isLearnable
            collected = itemData.isLearned
        end
        return not not collectable, not not collected, current, total
    end

    ---@param self CompactVendorFilterDropDownTemplate
    ---@param collected boolean
    ---@param current number
    ---@param total number
    ---@return CompactVendorFilterDropDownTemplateOption option
    local function GetCollectableOption(self, collected, current, total)
        local options = self.options
        local value ---@type number
        local text ---@type string
        if collected then
            if current == total then
                value = 1
                text = YES
            else
                value = 2
                text = PROFESSIONS_COLUMN_REAGENTS_PARTIAL
            end
        else
            value = 3
            text = NO
        end
        local option = self:GetOption(value)
        if not option then
            option = {} ---@diagnostic disable-line: missing-fields
            options[#options + 1] = option
        end
        option.value = value
        option.text = text
        return option
    end

    local filter = CompactVendorFilterDropDownTemplate:New(
        "Learnable: Collected", {},
        "itemLink", {},
        function(self)
            local items = self.parent:GetMerchantItems()
            local options = self.options
            local values = self.values
            table.wipe(values)
            for _, option in ipairs(options) do
                option.show = false
            end
            for _, itemData in ipairs(items) do
                local collectable, collected, current, total = GetCollectedStatus(itemData)
                if collectable then
                    local option = GetCollectableOption(self, collected, current, total)
                    option.show = true
                    if option.checked == nil then
                        option.checked = true
                    end
                    values[option.value] = true
                end
            end
        end,
        function(self, _, itemData)
            local collectable, collected, current, total = GetCollectedStatus(itemData)
            if not collectable then
                return
            end
            return GetCollectableOption(self, collected, current, total)
        end,
        ---@param value? number
        ---@param option? CompactVendorFilterDropDownTemplateOption
        function(_, value, option, itemData)
            if not value or not option then
                return
            end
            local collectable, collected, current, total = GetCollectedStatus(itemData)
            if not collectable then
                return
            end
            return value == option.value
        end
    )

    filter:Publish()

end
