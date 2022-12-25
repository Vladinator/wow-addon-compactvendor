local CompactVendorFilterDropDownToggleWrapperTemplate = CompactVendorFilterDropDownToggleWrapperTemplate ---@type CompactVendorFilterDropDownToggleWrapperTemplate

do

    local filter = CompactVendorFilterDropDownToggleWrapperTemplate:New(
        "Learnable",
        function(self, itemLink, itemData)
            if itemData.isHeirloom then
                return itemData.isKnownHeirloom ~= nil
            end
            return itemData.isLearnable and (itemData.isLearned ~= nil or itemData.isCollected ~= nil)
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
        "Learnable: Known/Collected",
        function(self, itemLink, itemData)
            if (not itemData.isHeirloom) and (not itemData.isLearnable) and (not itemData.isCollectedNum) then
                return
            end
            return itemData.isKnownHeirloom or itemData.isLearned or itemData.isCollected
        end,
        function(self, value)
            return value and YES or NO
        end,
        true
    )

    filter:Publish()

end
