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
            if (not itemData.isHeirloom) and (not itemData.isToy) and (not itemData.isLearnable) and (not itemData.isCollectedNum) then
                return
            end
            return itemData.isKnownHeirloom or itemData.isToyCollected or itemData.isLearned or (itemData.isCollectedNum and itemData.isCollectedNum > 0) or false
        end,
        function(self, value)
            return value and YES or NO
        end,
        true
    )

    filter:Publish()

end
