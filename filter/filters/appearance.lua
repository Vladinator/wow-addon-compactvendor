local CompactVendorFilterDropDownToggleWrapperTemplate = CompactVendorFilterDropDownToggleWrapperTemplate ---@type CompactVendorFilterDropDownToggleWrapperTemplate

local filter = CompactVendorFilterDropDownToggleWrapperTemplate:New(
    "Appearance",
    function(self, itemLink, itemData)
        if not itemData.isTransmog then
            return
        end
        if not itemData.isTransmogCollectable then
            return true
        end
        return not not itemData.isTransmogCollected
    end,
    function(self, value)
        return value and TRANSMOG_COLLECTED or NOT_COLLECTED
    end
)

filter:Publish()
