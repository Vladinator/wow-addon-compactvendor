local CompactVendorFilterDropDownToggleWrapperTemplate = CompactVendorFilterDropDownToggleWrapperTemplate ---@type CompactVendorFilterDropDownToggleWrapperTemplate

local filter = CompactVendorFilterDropDownToggleWrapperTemplate:New(
    "Known",
    function(self, itemLink, itemData)
        return itemData.isLearned
    end,
    function(self, value)
        return value and YES or NO
    end,
    true
)

filter:Publish()
