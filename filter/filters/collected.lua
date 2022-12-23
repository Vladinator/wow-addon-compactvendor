local CompactVendorFilterDropDownToggleWrapperTemplate = CompactVendorFilterDropDownToggleWrapperTemplate ---@type CompactVendorFilterDropDownToggleWrapperTemplate

local filter = CompactVendorFilterDropDownToggleWrapperTemplate:New(
    "Collected",
    function(self, itemLink, itemData)
        return itemData.isCollected
    end,
    function(self, value)
        return value and YES or NO
    end,
    true
)

filter:Publish()
