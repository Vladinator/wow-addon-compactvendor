local CompactVendorFilterDropDownToggleWrapperTemplate = CompactVendorFilterDropDownToggleWrapperTemplate ---@type CompactVendorFilterDropDownToggleWrapperTemplate

local filter = CompactVendorFilterDropDownToggleWrapperTemplate:New(
    "Usable",
    function(self, itemLink, itemData)
        return itemData.isUsable
    end,
    function(self, value)
        return value and YES or NO
    end,
    true
)

filter:Publish()
