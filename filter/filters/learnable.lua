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
            if itemData.isCollected then
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

    local filter = CompactVendorFilterDropDownToggleWrapperTemplate:New(
        "Learnable: Collected",
        function(self, itemLink, itemData)
            if (not itemData.isHeirloom) and (not itemData.isToy) and (not itemData.isCosmeticBundle) and (not itemData.isCollected) and (not itemData.isLearnable) then
                return
            end
            return itemData.isKnownHeirloom or itemData.isToyCollected or itemData.isCosmeticBundleCollected or itemData.isCollectedNum == itemData.isCollectedNumMax or itemData.isLearned or false
        end,
        function(self, value)
            return value and YES or NO
        end,
        true
    )

    filter:Publish()

end
