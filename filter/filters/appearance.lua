local CompactVendorFilterDropDownToggleWrapperTemplate = CompactVendorFilterDropDownToggleWrapperTemplate ---@type CompactVendorFilterDropDownToggleWrapperTemplate

do

    local filter = CompactVendorFilterDropDownToggleWrapperTemplate:New(
        "Appearance",
        function(self, itemLink, itemData)
            if itemData.isTransmog then
                return itemData.isTransmogCollectable ~= nil
            end
            return not not itemData.isTransmogCollected
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
        "Appearance: Collected",
        function(self, itemLink, itemData)
            if not itemData.isTransmog or not itemData.isTransmogCollectable then
                return
            end
            return itemData.isTransmogCollected
        end,
        function(self, value)
            return value and TRANSMOG_COLLECTED or NOT_COLLECTED
        end
    )

    filter:Publish()

end
